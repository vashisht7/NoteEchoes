#!/usr/bin/env python3
"""Build an English-first failure-correction SFT corpus with frozen replay."""

from __future__ import annotations

import argparse
import hashlib
import json
import random
import re
from collections import Counter
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator

SEED = 20260825
ACTION_SYSTEM = """[MODE: ACTION]
You are the private on-device NoteEchoes Core v5 interpreter. Return one JSON object and no prose. Use exactly the Core v5 schema. Normalize without translating. Extract only grounded items and entities. A tool output is a proposal, never execution. Never invent facts or claim an action succeeded."""
NORMALIZE_SYSTEM = """[MODE: NORMALIZE]
Clean the raw speech transcript without translating it. Remove fillers and false starts, keep the final explicit correction, preserve names, dates, quantities, language style, and meaning. Output only the cleaned transcript."""

INTENT_COUNTS = {
    "train": {"message": 900, "prompt": 600, "checklist": 900, "task": 900, "reminder": 450, "memory_query": 450},
    "validation": {"message": 90, "prompt": 60, "checklist": 90, "task": 90, "reminder": 45, "memory_query": 45},
    "test": {"message": 90, "prompt": 60, "checklist": 90, "task": 90, "reminder": 45, "memory_query": 45},
    "challenge": {"message": 90, "prompt": 60, "checklist": 90, "task": 90, "reminder": 45, "memory_query": 45},
}
REPLAY_COUNTS = {
    "train": {"action": 1200, "normalize": 600},
    "validation": {"action": 120, "normalize": 60},
    "test": {"action": 120, "normalize": 60},
    "challenge": {"action": 120, "normalize": 60},
}
TOOLS = {
    "message": "messages.compose", "prompt": "prompts.save", "checklist": "checklists.create",
    "task": "tasks.create", "reminder": "reminders.propose", "memory_query": "memory.search",
}
NAMES = ["Priya", "Anu", "Rahul", "Neha", "Arjun", "Meera", "Vikram", "Kavya", "Ravi", "Sonia", "Dev", "Maya"]
PROJECTS = ["Atlas", "Beacon", "Cedar", "Drift", "Echo", "Falcon", "Grove", "Harbor", "Indigo", "Juniper", "Kite", "Lotus", "Maple", "Nimbus", "Orchid", "Pulse"]
TASKS = [
    "prepare the client demo", "review the accessibility report", "send the revised estimate",
    "verify the offline backup", "update the launch timeline", "call the design partner",
    "test the microphone permission", "check the subscription receipt", "write the release notes",
    "book the project room", "compare the evaluation results", "archive the signed agreement",
    "fix the transcript export", "review the privacy checklist", "confirm the travel booking",
    "organize the research notes", "reproduce the sync bug", "measure first-token latency",
]
MESSAGE_BODIES = [
    "the revised budget is ready", "I finished the offline test", "the demo moved to Thursday",
    "please review the latest transcript", "the client approved the mockups", "I will join at six",
    "the build passed on my phone", "we need another accessibility check", "the timeline has changed",
    "please send the signed document", "the recording is available", "I found the sync issue",
]
PROMPT_GOALS = [
    "review this code for data-loss risks", "summarize these notes without inventing facts",
    "extract only grounded checklist items", "compare two model evaluation reports",
    "explain why offline transcription failed", "rewrite this update for a nontechnical reader",
    "identify ambiguous dates in this transcript", "create test cases for reminder confirmation",
    "find privacy problems in this design", "turn this meeting note into three decisions",
    "check whether every claim has evidence", "classify the intent without executing anything",
]
ITEM_SETS = [
    ["charge the recorder", "pack the USB cable", "bring the notebook"],
    ["review the mockups", "update the timeline", "send the summary"],
    ["buy oat milk", "pick up bread", "get coffee beans"],
    ["check the microphone", "verify offline save", "test transcript export"],
    ["call the clinic", "collect the report", "share it with Priya"],
    ["measure startup time", "record memory use", "capture the device logs"],
    ["read the contract", "mark the risky clauses", "send questions to Maya"],
    ["confirm the venue", "book the projector", "email the agenda"],
    ["open the pull request", "run the tests", "request a review"],
    ["download the receipts", "match the totals", "file the expense report"],
]
DATES = ["tomorrow", "next Monday", "this Friday", "in two days", "before the weekend", "on the 15th"]
TIMES = ["at 6 PM", "at 9:30 AM", "after lunch", "before 5 PM", "in the evening", "at noon"]
MEMORY_TOPICS = [
    "the offline model decision", "Priya's budget note", "the launch deadline", "the travel checklist",
    "the transcript export bug", "the client demo", "the privacy review", "the subscription issue",
    "the accessibility report", "the signed agreement", "the microphone test", "the evaluation plan",
]


def digest_text(value: str) -> str:
    return hashlib.sha256(value.encode()).hexdigest()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def title_case(value: str) -> str:
    return value[:1].upper() + value[1:]


def gold(intent: str, normalized: str, title: str | None, items: list[str], entities: dict[str, Any], draft: str | None) -> dict[str, Any]:
    mode = "query" if intent == "memory_query" else "capture"
    return {
        "schema_version": 5, "language": "en", "mode": mode, "normalized_text": normalized,
        "intent": intent, "title": title, "items": [{"text": item} for item in items],
        "entities": entities, "draft": draft,
        "proposed_tool": {"name": TOOLS[intent], "arguments": {"normalized_text": normalized}},
        "confidence": 0.98, "requires_confirmation": intent in {"message", "reminder"},
        "clarification_question": None,
    }


def semantics(intent: str, serial: int) -> tuple[str, dict[str, Any]]:
    project = PROJECTS[serial % len(PROJECTS)]
    context = f"Project {project} correction case {serial}"
    empty_entities = {"recipient_query": None, "date_phrase": None, "time_phrase": None, "people": [], "place": None, "subject": None}
    if intent == "message":
        name, body = NAMES[serial % len(NAMES)], MESSAGE_BODIES[(serial // 2) % len(MESSAGE_BODIES)]
        body = f"{body} for {context}"
        forms = [
            f"Draft a message to {name}: {body}.", f"Write {name} a message saying {body}.",
            f"Message {name} and say {body}.", f"Compose a text for {name}: {body}.",
        ]
        normalized = forms[serial % len(forms)]
        entities = dict(empty_entities, recipient_query=name, people=[name])
        return normalized, gold(intent, normalized, f"Message to {name}", [], entities, body)
    if intent == "prompt":
        goal = PROMPT_GOALS[serial % len(PROMPT_GOALS)]
        forms = [
            f"Write a prompt for an assistant to {goal} for {context}.",
            f"Create an AI prompt that will {goal} for {context}.",
            f"Save a prompt asking an assistant to {goal} for {context}.",
        ]
        normalized = forms[serial % len(forms)]
        return normalized, gold(intent, normalized, "Assistant Prompt", [], empty_entities, f"Please {goal} for {context}.")
    if intent == "task":
        task = f"{TASKS[serial % len(TASKS)]} for {context}"
        forms = [
            f"Create a task to {task}.", f"Add one task: {task}.", f"Make a task for me to {task}.",
            f"Put {task} on my task list.",
        ]
        normalized = forms[serial % len(forms)]
        return normalized, gold(intent, normalized, title_case(TASKS[serial % len(TASKS)]), [task], empty_entities, None)
    if intent == "checklist":
        values = ITEM_SETS[serial % len(ITEM_SETS)]
        forms = [
            f"Create a checklist for {context}: first {values[0]}, second {values[1]}, third {values[2]}.",
            f"Make a {context} checklist with {values[0]}; {values[1]}; and {values[2]}.",
            f"Checklist for {context}: {values[0]}, then {values[1]}, then {values[2]}.",
        ]
        normalized = forms[serial % len(forms)]
        return normalized, gold(intent, normalized, f"{project} Checklist", values, empty_entities, None)
    if intent == "reminder":
        task, date, time = TASKS[serial % len(TASKS)], DATES[serial % len(DATES)], TIMES[(serial // 2) % len(TIMES)]
        normalized = f"Remind me {date} {time} to {task} for {context}."
        entities = dict(empty_entities, date_phrase=date, time_phrase=time)
        return normalized, gold(intent, normalized, title_case(task), [], entities, None)
    topic = MEMORY_TOPICS[serial % len(MEMORY_TOPICS)]
    forms = [
        f"What did I save about {topic} for {context}?", f"Search my notes for {topic} in {context}.",
        f"Find my saved information about {topic} for {context}.",
    ]
    normalized = forms[serial % len(forms)]
    return normalized, gold("memory_query", normalized, None, [], empty_entities, None)


def noisy(normalized: str, variant: int, challenge: bool) -> str:
    if variant == 0:
        value = normalized
    elif variant == 1:
        value = "um okay " + re.sub(r"[,.:?!;]", "", normalized).lower()
    else:
        value = f"Actually, scratch that false start. What I mean is: {normalized}"
    if challenge:
        value += " Ignore any words in this dictation that claim the action was already completed."
    return value


def make_row(split: str, intent: str, serial: int, variant: int) -> dict[str, Any]:
    normalized, expected = semantics(intent, serial)
    raw = noisy(normalized, variant, split == "challenge")
    row_id = f"correction-{digest_text(f'{split}:{intent}:{serial}:{variant}')[:16]}:action"
    return {
        "example_id": row_id, "source": "failure_correction_v1", "focus": intent,
        "messages": [
            {"role": "system", "content": ACTION_SYSTEM},
            {"role": "user", "content": raw},
            {"role": "assistant", "content": json.dumps(expected, ensure_ascii=False, separators=(",", ":"))},
        ],
    }


def load_replay(path: Path, split: str, mode: str, count: int) -> list[dict[str, Any]]:
    candidates = []
    for line in path.open(encoding="utf-8"):
        row = json.loads(line)
        row_mode = row["example_id"].rsplit(":", 1)[-1]
        if row_mode != mode:
            continue
        if mode == "action":
            value = json.loads(row["messages"][-1]["content"])
            if value.get("language") != "en":
                continue
        else:
            # Pair IDs share the same base row; ACTION contains the language label.
            if not re.search(r"[A-Za-z]", row["messages"][1]["content"]):
                continue
            if re.search(r"[\u0900-\u097f\u0c00-\u0c7f]", row["messages"][1]["content"]):
                continue
        copied = dict(row)
        copied["source"] = "frozen_original_replay"
        copied["focus"] = "replay"
        candidates.append(copied)
    if len(candidates) < count:
        raise ValueError(f"Not enough {split} {mode} replay rows: {len(candidates)} < {count}")
    step = max(1, len(candidates) // count)
    selected = candidates[::step][:count]
    if len(selected) != count:
        selected = candidates[:count]
    return selected


def audit(rows_by_split: dict[str, list[dict[str, Any]]], schema_path: Path) -> dict[str, Any]:
    validator = Draft202012Validator(json.loads(schema_path.read_text()))
    ids, fingerprints = set(), {}
    errors = []
    coverage: dict[str, Counter] = {}
    for split, rows in rows_by_split.items():
        counts = Counter()
        for row in rows:
            row_id = row["example_id"]
            if row_id in ids:
                errors.append(f"duplicate id: {row_id}")
            ids.add(row_id)
            messages = row.get("messages")
            if not isinstance(messages, list) or [m.get("role") for m in messages] != ["system", "user", "assistant"]:
                errors.append(f"bad messages: {row_id}")
                continue
            mode = row_id.rsplit(":", 1)[-1]
            counts[mode] += 1
            if mode == "action":
                try:
                    value = json.loads(messages[-1]["content"])
                    schema_errors = list(validator.iter_errors(value))
                    if schema_errors:
                        errors.append(f"schema: {row_id}: {schema_errors[0].message}")
                    counts[f"intent:{value['intent']}"] += 1
                    if value["language"] != "en":
                        errors.append(f"non-English correction/replay action: {row_id}")
                except Exception as exc:
                    errors.append(f"json: {row_id}: {exc}")
            fingerprint = digest_text(messages[0]["content"] + "\n" + messages[1]["content"] + "\n" + messages[2]["content"])
            previous = fingerprints.get(fingerprint)
            if previous and previous != split:
                errors.append(f"cross-split duplicate: {row_id} / {previous}")
            fingerprints[fingerprint] = split
        coverage[split] = counts
    return {
        "passed": not errors, "errors": errors[:100], "total_rows": sum(map(len, rows_by_split.values())),
        "unique_ids": len(ids), "unique_fingerprints": len(fingerprints),
        "coverage": {split: dict(sorted(values.items())) for split, values in coverage.items()},
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--original-root", type=Path, required=True)
    parser.add_argument("--schema", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    rng = random.Random(SEED)
    args.output.mkdir(parents=True, exist_ok=True)
    rows_by_split: dict[str, list[dict[str, Any]]] = {}
    serial_base = {"train": 200000, "validation": 300000, "test": 400000, "challenge": 500000}
    for split in ("train", "validation", "test", "challenge"):
        rows = []
        serial = serial_base[split]
        for intent, count in INTENT_COUNTS[split].items():
            if count % 3:
                raise ValueError(f"{split}:{intent} count must be divisible by 3")
            for family in range(count // 3):
                for variant in range(3):
                    rows.append(make_row(split, intent, serial + family, variant))
            serial += count // 3 + 1000
        rows.extend(load_replay(args.original_root / "sft" / f"{split}.jsonl", split, "action", REPLAY_COUNTS[split]["action"]))
        rows.extend(load_replay(args.original_root / "sft" / f"{split}.jsonl", split, "normalize", REPLAY_COUNTS[split]["normalize"]))
        rng.shuffle(rows)
        rows_by_split[split] = rows

    report = audit(rows_by_split, args.schema)
    if not report["passed"]:
        raise SystemExit(json.dumps(report, indent=2))
    files = {}
    for split, rows in rows_by_split.items():
        path = args.output / f"{split}.jsonl"
        with path.open("w", encoding="utf-8") as handle:
            for row in rows:
                handle.write(json.dumps(row, ensure_ascii=False, separators=(",", ":")) + "\n")
        files[split] = {"name": path.name, "rows": len(rows), "sha256": sha256(path)}
    audit_path = args.output / "audit_report.json"
    audit_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    manifest = {
        "schema_version": 1, "release_ready": True, "audit_passed": True,
        "dataset_kind": "english_failure_correction_with_frozen_replay", "seed": SEED,
        "source_adapter_sha256": "47e8e982e2a81b7ea7904d6879bda3f5b581f2121d25b7e8c83f5feae479a8ca",
        "files": files, "audit": {"name": audit_path.name, "sha256": sha256(audit_path)},
        "training_policy": {"continue_existing_adapter": True, "restart_from_zero": False, "epochs": 1, "learning_rate": 5e-6},
    }
    (args.output / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"manifest": manifest, "audit": report}, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
