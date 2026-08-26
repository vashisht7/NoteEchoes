#!/usr/bin/env python3
"""Fail-closed release audit for Core v5 annotated JSONL files."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


ALLOWED_TOOLS = {
    "note": "notes.create", "idea": "notes.create", "decision": "notes.create",
    "project_update": "notes.create", "checklist": "checklists.create",
    "task": "tasks.create", "reminder": "reminders.propose",
    "calendar": "calendar.propose_event", "message": "messages.compose",
    "email": "email.compose", "prompt": "prompts.save", "memory_query": "memory.search",
    "cancel": None, "clarify": None, "noop": None,
}
ROOT_KEYS = {
    "schema_version", "language", "mode", "normalized_text", "intent", "title",
    "items", "entities", "draft", "proposed_tool", "confidence",
    "requires_confirmation", "clarification_question",
}
ENTITY_KEYS = {"recipient_query", "date_phrase", "time_phrase", "people", "place", "subject"}
TOOL_KEYS = {"name", "arguments"}
LANGUAGES = {"en", "hi", "te", "hi-roman", "te-roman", "mixed", "unknown"}
MODES = {"capture", "query", "control"}


def structural_errors(row: dict[str, Any]) -> list[str]:
    problems: list[str] = []
    gold = row.get("gold")
    if not isinstance(gold, dict):
        return ["gold_not_object"]
    if set(gold) != ROOT_KEYS:
        problems.append("gold_root_keys_mismatch")
    entities = gold.get("entities")
    if not isinstance(entities, dict) or set(entities) != ENTITY_KEYS:
        problems.append("entity_keys_mismatch")
    tool = gold.get("proposed_tool")
    if not isinstance(tool, dict) or set(tool) != TOOL_KEYS or not isinstance(tool.get("arguments"), dict):
        problems.append("tool_shape_invalid")
    if gold.get("schema_version") != 5:
        problems.append("schema_version_invalid")
    if gold.get("language") not in LANGUAGES or gold.get("mode") not in MODES or gold.get("intent") not in ALLOWED_TOOLS:
        problems.append("enum_invalid")
    if not isinstance(gold.get("normalized_text"), str) or not gold["normalized_text"].strip() or len(gold["normalized_text"]) > 8000:
        problems.append("normalized_text_invalid")
    title = gold.get("title")
    if title is not None and (not isinstance(title, str) or not title.strip() or len(title) > 96):
        problems.append("title_invalid")
    items = gold.get("items")
    if not isinstance(items, list) or len(items) > 50 or any(not isinstance(item, dict) or set(item) != {"text"} or not isinstance(item["text"], str) or not item["text"].strip() for item in items):
        problems.append("items_invalid")
    confidence = gold.get("confidence")
    if not isinstance(confidence, (int, float)) or isinstance(confidence, bool) or not 0 <= confidence <= 1:
        problems.append("confidence_invalid")
    if not isinstance(gold.get("requires_confirmation"), bool):
        problems.append("confirmation_invalid")
    if gold.get("mode") == "query" and gold.get("intent") != "memory_query":
        problems.append("query_mode_intent_invalid")
    if gold.get("mode") == "control" and gold.get("intent") not in {"cancel", "clarify", "noop"}:
        problems.append("control_mode_intent_invalid")
    if gold.get("intent") == "clarify" and not gold.get("clarification_question"):
        problems.append("clarification_missing")
    if not re.fullmatch(r"nev5-[a-f0-9]{16}", str(row.get("example_id", ""))):
        problems.append("example_id_invalid")
    if not re.fullmatch(r"fam-[a-f0-9]{16}", str(row.get("semantic_family_id", ""))):
        problems.append("family_id_invalid")
    return problems


def normalized(value: str) -> str:
    return re.sub(r"[^\w]+", " ", value.casefold(), flags=re.UNICODE).strip()


def simhash(value: str) -> int:
    compact = normalized(value).replace(" ", "_")
    features = {compact[index:index + 5] for index in range(max(1, len(compact) - 4))}
    weights = [0] * 64
    for feature in features:
        digest = int.from_bytes(hashlib.sha256(feature.encode("utf-8")).digest()[:8], "big")
        for bit in range(64):
            weights[bit] += 1 if digest & (1 << bit) else -1
    return sum((1 << bit) for bit, weight in enumerate(weights) if weight >= 0)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+", type=Path)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument("--release", action="store_true", help="enforce all human-review and target-count gates")
    parser.add_argument("--experimental-synthetic-release", action="store_true", help="enforce target counts while accepting only explicitly synthetic, unreviewed rows")
    args = parser.parse_args()
    errors: list[dict[str, Any]] = []
    counts: Counter[str] = Counter()
    family_splits: dict[str, set[str]] = defaultdict(set)
    text_splits: dict[str, set[str]] = defaultdict(set)
    hashes: dict[str, str] = {}
    signatures: list[tuple[str, str, str, int, str]] = []
    rows = 0

    for path in args.files:
        hashes[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
        for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            rows += 1
            try:
                row = json.loads(line)
            except json.JSONDecodeError as exc:
                errors.append({"file": str(path), "line": line_no, "code": "invalid_json", "detail": str(exc)})
                continue
            split = row.get("split")
            gold = row.get("gold") or {}
            review = row.get("review") or {}
            intent = gold.get("intent")
            counts[f"split:{split}"] += 1
            counts[f"language:{row.get('language')}"] += 1
            counts[f"intent:{intent}"] += 1
            counts[f"review:{review.get('status')}"] += 1
            family_splits[str(row.get("semantic_family_id"))].add(str(split))
            text_splits[normalized(str(row.get("raw_transcript", "")))].add(str(split))
            semantic_key = json.dumps({
                "intent": gold.get("intent"), "title": gold.get("title"),
                "items": gold.get("items"), "entities": gold.get("entities"),
                "draft": gold.get("draft"),
                "scenario_reference": (re.search(r"\bwork item\s+\d+\b", str(gold.get("normalized_text", "")), re.IGNORECASE) or [None])[0],
            }, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
            signatures.append((str(row.get("example_id")), str(split), str(row.get("raw_transcript", "")), simhash(str(row.get("raw_transcript", ""))), semantic_key))
            for problem in structural_errors(row):
                errors.append({"file": str(path), "line": line_no, "code": problem})
            expected_tool = ALLOWED_TOOLS.get(intent, "__invalid__")
            actual_tool = (gold.get("proposed_tool") or {}).get("name")
            if expected_tool != actual_tool:
                errors.append({"file": str(path), "line": line_no, "code": "tool_intent_mismatch", "detail": f"{intent} -> {actual_tool}"})
            raw = str(row.get("raw_transcript", ""))
            for span in row.get("grounding_spans") or []:
                start, end = span.get("start"), span.get("end")
                if not isinstance(start, int) or not isinstance(end, int) or raw[start:end] != span.get("text"):
                    errors.append({"file": str(path), "line": line_no, "code": "invalid_grounding_span", "detail": span})
            if args.release and split in {"validation", "test", "challenge"}:
                if review.get("status") != "approved" or not review.get("reviewer_id") or not review.get("reviewed_at"):
                    errors.append({"file": str(path), "line": line_no, "code": "nontraining_not_human_approved"})
                if row.get("language") in {"hi", "te", "hi-roman", "te-roman", "mixed"} and not review.get("native_language_verified"):
                    errors.append({"file": str(path), "line": line_no, "code": "native_language_review_missing"})
            if args.experimental_synthetic_release:
                source = row.get("source") or {}
                consent = row.get("consent") or {}
                if source.get("type") != "synthetic" or source.get("synthetic") is not True:
                    errors.append({"file": str(path), "line": line_no, "code": "synthetic_waiver_contains_nonsynthetic_source"})
                if consent.get("status") != "not_applicable":
                    errors.append({"file": str(path), "line": line_no, "code": "synthetic_waiver_consent_mismatch"})

    for family, splits in family_splits.items():
        clean = splits - {"quarantine"}
        if len(clean) > 1:
            errors.append({"code": "semantic_family_leakage", "detail": {"family": family, "splits": sorted(clean)}})
    for text, splits in text_splits.items():
        clean = splits - {"quarantine"}
        if text and len(clean) > 1:
            errors.append({"code": "exact_text_leakage", "detail": {"text": text[:160], "splits": sorted(clean)}})
    bands: dict[tuple[int, int], list[tuple[str, str, str, int, str]]] = defaultdict(list)
    checked_pairs: set[tuple[str, str]] = set()
    for entry in signatures:
        for band in range(4):
            bands[(band, (entry[3] >> (band * 16)) & 0xFFFF)].append(entry)
    for bucket in bands.values():
        for left_index, left in enumerate(bucket):
            for right in bucket[left_index + 1:]:
                pair = tuple(sorted((left[0], right[0])))
                if pair in checked_pairs or left[1] == right[1] or left[4] != right[4] or "quarantine" in {left[1], right[1]}:
                    continue
                checked_pairs.add(pair)
                distance = (left[3] ^ right[3]).bit_count()
                if distance <= 3:
                    errors.append({"code": "near_duplicate_leakage", "detail": {"left": left[0], "right": right[0], "splits": [left[1], right[1]], "hamming": distance}})
    if args.release or args.experimental_synthetic_release:
        targets = {"train": 30000, "validation": 2400, "test": 2400, "challenge": 1200}
        for split, target in targets.items():
            actual = counts[f"split:{split}"]
            if actual != target:
                errors.append({"code": "split_count_mismatch", "detail": {"split": split, "expected": target, "actual": actual}})

    report = {
        "release_mode": args.release,
        "experimental_synthetic_release": args.experimental_synthetic_release,
        "review_policy": "named_human_review" if args.release else ("synthetic_waiver_user_authorized_2026-08-24" if args.experimental_synthetic_release else "structural_only"),
        "passed": not errors, "rows": rows,
        "counts": dict(sorted(counts.items())), "file_sha256": hashes,
        "errors": errors[:1000], "error_count": len(errors),
    }
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if not errors else 2


if __name__ == "__main__":
    raise SystemExit(main())
