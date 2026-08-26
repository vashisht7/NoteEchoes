#!/usr/bin/env python3
"""Import legacy NoteEchoes corpora into an auditable Core v5 staging set.

This command deliberately never writes to ready/. Legacy approval labels are
not sufficient for the v5 contract, so every imported row remains unreviewed.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import zipfile
from collections import Counter
from pathlib import Path
from typing import Any, Iterable


LANGUAGE_MAP = {
    "en": "en", "hi": "hi", "te": "te", "hi-roman": "hi-roman",
    "te-roman": "te-roman", "hi-en-roman": "hi-roman",
    "te-en-roman": "te-roman", "hi-en": "mixed", "te-en": "mixed",
}
TOOL_BY_INTENT = {
    "note": "notes.create", "idea": "notes.create", "decision": "notes.create",
    "project_update": "notes.create", "checklist": "checklists.create",
    "task": "tasks.create", "reminder": "reminders.propose",
    "calendar": "calendar.propose_event", "message": "messages.compose",
    "email": "email.compose", "prompt": "prompts.save",
    "memory_query": "memory.search", "cancel": None, "clarify": None, "noop": None,
}


def stable_id(prefix: str, *parts: str) -> str:
    value = "\x1f".join(parts).encode("utf-8")
    return f"{prefix}-{hashlib.sha256(value).hexdigest()[:16]}"


def compact(text: str) -> str:
    return re.sub(r"\s+", " ", text.strip())


def script_of(text: str) -> str:
    has_te = bool(re.search(r"[\u0C00-\u0C7F]", text))
    has_hi = bool(re.search(r"[\u0900-\u097F]", text))
    has_latin = bool(re.search(r"[A-Za-z]", text))
    active = sum((has_te, has_hi, has_latin))
    if active > 1:
        return "mixed"
    if has_te:
        return "telugu"
    if has_hi:
        return "devanagari"
    if has_latin:
        return "latin"
    return "unknown"


def spans(raw: str, field: str, values: Iterable[str]) -> list[dict[str, Any]]:
    result: list[dict[str, Any]] = []
    raw_lower = raw.casefold()
    cursor = 0
    for value in values:
        value = compact(value)
        if not value:
            continue
        start = raw_lower.find(value.casefold(), cursor)
        if start < 0:
            start = raw_lower.find(value.casefold())
        if start >= 0:
            result.append({"field": field, "text": raw[start:start + len(value)], "start": start, "end": start + len(value)})
            cursor = start + len(value)
    return result


def blank_entities() -> dict[str, Any]:
    return {"recipient_query": None, "date_phrase": None, "time_phrase": None, "people": [], "place": None, "subject": None}


def envelope(raw: str, language: str, intent: str, *, title: str | None = None,
             items: list[str] | None = None, entities: dict[str, Any] | None = None,
             draft: str | None = None, clarification: str | None = None,
             confidence: float = 0.9) -> dict[str, Any]:
    mode = "query" if intent == "memory_query" else ("control" if intent in {"cancel", "clarify", "noop"} else "capture")
    needs_confirmation = intent in {"reminder", "calendar", "message", "email", "clarify"}
    args: dict[str, Any] = {}
    if TOOL_BY_INTENT[intent] is not None:
        args = {"normalized_text": compact(raw)}
    return {
        "schema_version": 5,
        "language": language,
        "mode": mode,
        "normalized_text": compact(raw),
        "intent": intent,
        "title": title,
        "items": [{"text": compact(item)} for item in (items or [])],
        "entities": entities or blank_entities(),
        "draft": draft,
        "proposed_tool": {"name": TOOL_BY_INTENT[intent], "arguments": args},
        "confidence": confidence,
        "requires_confirmation": needs_confirmation,
        "clarification_question": clarification,
    }


def annotation(source_type: str, source_name: str, source_id: str, source_split: str,
               language: str, raw: str, gold: dict[str, Any], grounding: list[dict[str, Any]],
               *, synthetic: bool, safety_tags: list[str] | None = None) -> dict[str, Any]:
    canonical = compact(raw).casefold()
    family = stable_id("fam", source_type, canonical)
    example = stable_id("nev5", source_type, source_id, canonical)
    return {
        "example_id": example,
        "semantic_family_id": family,
        "scenario_id": f"legacy:{source_type}:{source_id}",
        "speaker_id": None,
        "session_id": None,
        "split": source_split if source_split in {"train", "validation", "test", "challenge"} else "quarantine",
        "source": {"type": source_type, "name": source_name, "source_id": source_id, "license": "project-internal", "synthetic": synthetic},
        "consent": {"status": "not_applicable", "record_id": None},
        "language": language,
        "script": script_of(raw),
        "is_code_mixed": language == "mixed" or script_of(raw) == "mixed",
        "raw_transcript": compact(raw),
        "gold": gold,
        "grounding_spans": grounding,
        "ambiguity": "none",
        "asr_tags": [],
        "safety_tags": safety_tags or [],
        "review": {"status": "unreviewed", "reviewer_id": None, "reviewed_at": None, "native_language_verified": False},
        "history": [{"event": "legacy_import", "source_split": source_split}],
    }


def messages(row: dict[str, Any]) -> tuple[str, dict[str, Any]]:
    msgs = row["messages"]
    raw = next(m["content"] for m in msgs if m["role"] == "user")
    raw = re.sub(r"^\[mode:[^\n]+\]\n\[language:[^\n]+\]\n", "", raw)
    answer = json.loads(next(m["content"] for m in msgs if m["role"] == "assistant"))
    return compact(raw), answer


def import_v4(path: Path) -> Iterable[dict[str, Any]]:
    split = re.search(r"noteechoes_(train|validation|test|challenge)_v4", path.name).group(1)  # type: ignore[union-attr]
    for index, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        row = json.loads(line)
        raw, old = messages(row)
        language = LANGUAGE_MAP.get(old.get("language"), "unknown")
        actions = old.get("actions") or []
        safety: list[str] = []
        if old.get("mode") == "query":
            intent = "memory_query"
        elif len(actions) > 1:
            # Singular v5 provider semantics cannot safely infer an execution order.
            intent = "clarify"
            safety.append("legacy_multi_action_requires_reannotation")
        elif actions:
            kind = actions[0].get("kind")
            intent = {"task": "checklist" if actions[0].get("items") else "task", "reminder": "reminder", "calendar_event": "calendar"}.get(kind, "note")
        else:
            intent = {"idea": "idea", "decision": "decision", "project_update": "project_update"}.get(old.get("kind"), "note")
        action = actions[0] if len(actions) == 1 else {}
        entities = blank_entities()
        entities.update({
            "date_phrase": action.get("date"), "time_phrase": action.get("time"),
            "people": action.get("people") or [], "place": action.get("place"),
        })
        items = action.get("items") or []
        question = "Which action should I prepare first?" if intent == "clarify" else old.get("ask")
        gold = envelope(raw, language, intent, title=old.get("title"), items=items, entities=entities,
                        clarification=question, confidence=0.85)
        grounding = spans(raw, "items", items)
        grounding += spans(raw, "entities.people", entities["people"])
        grounding += spans(raw, "entities.date_phrase", [entities["date_phrase"]] if entities["date_phrase"] else [])
        grounding += spans(raw, "entities.time_phrase", [entities["time_phrase"]] if entities["time_phrase"] else [])
        yield annotation("core_v4", "NoteEchoes Core v4", f"{split}:{index}", split, language, raw, gold, grounding, synthetic=True, safety_tags=safety)


def import_v2(zip_path: Path) -> Iterable[dict[str, Any]]:
    member = "noteechoes_natural_speech_pack_v2/data/train_reviewable.jsonl"
    with zipfile.ZipFile(zip_path) as archive, archive.open(member) as handle:
        for raw_line in handle:
            row = json.loads(raw_line)
            # NORMALIZE rows have plain-text completions and are kept for a
            # separate mode-specific curriculum builder. This importer emits
            # only complete action-envelope annotations.
            if row.get("mode") != "interpret":
                continue
            raw, old = messages(row)
            language = LANGUAGE_MAP.get(row.get("language"), "unknown")
            old_intent = row.get("intent")
            intent = {
                "plain_note": "note", "task": "task", "reminder": "reminder",
                "calendar_event": "calendar", "message_draft": "message",
                "email_draft": "email", "agent_prompt": "prompt", "idea": "idea",
                "decision": "decision", "project_update": "project_update",
                "question": "memory_query", "none": "noop",
            }.get(old_intent)
            if intent is None:
                continue
            entities = blank_entities()
            people = old.get("people") or []
            entities["people"] = people
            reminder = old.get("reminder") or {}
            calendar = old.get("calendar_event") or {}
            communication = old.get("communication") or {}
            entities.update({
                "recipient_query": communication.get("recipient"),
                "date_phrase": calendar.get("date_text"),
                "time_phrase": reminder.get("trigger_text") or calendar.get("time_text"),
                "place": calendar.get("location"),
                "subject": communication.get("subject"),
            })
            task = old.get("task") or {}
            items = task.get("items") or []
            if intent == "task" and len(items) > 1:
                intent = "checklist"
            draft = communication.get("draft") or (old.get("agent_prompt") or {}).get("prompt")
            title = old.get("title")
            gold = envelope(raw, language, intent, title=title, items=items, entities=entities, draft=draft, confidence=float(old.get("confidence", 0.8)))
            grounding = spans(raw, "items", items) + spans(raw, "entities.people", people)
            yield annotation("v2_archive", "Note Echoes Multilingual v2", row["id"], "train", language, raw, gold, grounding, synthetic=True,
                             safety_tags=["legacy_ai_preapproved_not_human_reviewed"])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--v4-ready", type=Path, required=True)
    parser.add_argument("--v2-zip", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)

    rows: list[dict[str, Any]] = []
    for split in ("train", "validation", "test", "challenge"):
        rows.extend(import_v4(args.v4_ready / f"noteechoes_{split}_v4.jsonl"))
    if args.v2_zip:
        rows.extend(import_v2(args.v2_zip))

    unique: dict[str, dict[str, Any]] = {}
    duplicate_ids: list[str] = []
    for row in rows:
        key = compact(row["raw_transcript"]).casefold()
        if key in unique:
            duplicate_ids.append(row["example_id"])
            continue
        unique[key] = row
    rows = sorted(unique.values(), key=lambda r: r["example_id"])
    output = args.output / "core_v5_staging.jsonl"
    output.write_text("".join(json.dumps(row, ensure_ascii=False, separators=(",", ":")) + "\n" for row in rows), encoding="utf-8")
    counts = Counter()
    for row in rows:
        counts[f"split:{row['split']}"] += 1
        counts[f"language:{row['language']}"] += 1
        counts[f"intent:{row['gold']['intent']}"] += 1
        counts[f"source:{row['source']['type']}"] += 1
        counts[f"review:{row['review']['status']}"] += 1
    report = {
        "status": "staging_only_not_training_ready",
        "rows": len(rows), "exact_duplicates_removed": len(duplicate_ids),
        "counts": dict(sorted(counts.items())),
        "sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
        "blocking_gates": [
            "all labels require Core v5 review",
            "validation/test/challenge require 100% named human approval",
            "Hindi and Telugu require native-language verification",
            "grounding spans require completion for paraphrased legacy labels"
        ],
    }
    (args.output / "staging_report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
