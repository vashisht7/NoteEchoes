#!/usr/bin/env python3
"""Build a leakage-checked corpus for mode routing and reminder anti-regression."""

from __future__ import annotations

import argparse
import hashlib
import json
import random
from collections import Counter
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator

SEED = 2026082602
SOURCE_ADAPTER_SHA256 = "fa00273d4399461b3d8c9e2642c0e8716cf76dc7a4f9bfcb9244c2f96b35dc8b"

ACTION_SYSTEM = """[MODE: ACTION]
You are the private on-device NoteEchoes Core v5 interpreter. Return one JSON object and no prose. Use exactly the Core v5 schema. Normalize without translating. Extract only grounded items and entities. A tool output is a proposal, never execution. Never invent facts or claim an action succeeded."""

PROJECTS = ["Aurora", "Birch", "Cobalt", "Delta", "Elm", "Fjord", "Quartz", "Willow"]
ACTIONS = [
    "confirm the venue booking", "review the export manifest", "test the offline cache",
    "archive the approval email", "measure launch latency", "organize the interview notes",
    "check the renewal invoice", "prepare the design handoff", "verify the encrypted backup",
    "book the planning room", "update the accessibility checklist", "call the print vendor",
]
PEOPLE = ["Aarav", "Anika", "Dev", "Isha", "Kabir", "Meera", "Neel", "Sara"]
DATE_TIME = [
    ("tomorrow", "at 4 PM"), ("this Friday", "at 10:15 AM"),
    ("in three days", "in the evening"), ("next Monday", "before noon"),
    ("on the 18th", "at 2:30 PM"), ("this weekend", "in the morning"),
]
AMBIGUOUS = [
    ("Remind me to follow up later.", "When should I remind you, and what should you follow up about?"),
    ("Remind me to send it to them.", "When should I remind you, what should I send, and to whom?"),
    ("Put that on my task list.", "What should I add to your task list?"),
    ("Find what I saved about it.", "What topic should I search your saved notes for?"),
]


def compact(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def entities(*, recipient=None, date=None, time=None) -> dict[str, Any]:
    return {
        "recipient_query": recipient, "date_phrase": date, "time_phrase": time,
        "people": [recipient] if recipient else [], "place": None, "subject": None,
    }


def output(*, normalized: str, mode: str, intent: str, title=None, items=None,
           entity_values=None, tool=None, confirmation=False, question=None,
           confidence=0.98) -> dict[str, Any]:
    return {
        "schema_version": 5, "language": "en", "mode": mode,
        "normalized_text": normalized, "intent": intent, "title": title,
        "items": items or [], "entities": entity_values or entities(), "draft": None,
        "proposed_tool": {"name": tool, "arguments": {"normalized_text": normalized} if tool else {}},
        "confidence": confidence, "requires_confirmation": confirmation,
        "clarification_question": question,
    }


def row(split: str, focus: str, serial: int, raw: str, expected: dict[str, Any]) -> dict[str, Any]:
    key = hashlib.sha256(f"{split}:{focus}:{serial}:{raw}".encode()).hexdigest()[:16]
    return {
        "example_id": f"gate3-{key}:action", "source": "mode_reminder_antiregression",
        "focus": focus, "messages": [
            {"role": "system", "content": ACTION_SYSTEM},
            {"role": "user", "content": raw},
            {"role": "assistant", "content": compact(expected)},
        ],
    }


def task_row(split: str, serial: int) -> dict[str, Any]:
    action, project = ACTIONS[serial % len(ACTIONS)], PROJECTS[(serial // len(ACTIONS)) % len(PROJECTS)]
    normalized = f"Put {action} for Project {project} reference {700000 + serial} on my task list."
    forms = [normalized, f"Um okay, put {action} for project {project} reference {700000 + serial} on my task list",
             f"Actually, add this task: {action} for Project {project}, reference {700000 + serial}."]
    raw = forms[serial % len(forms)]
    expected = output(normalized=normalized, mode="capture", intent="task",
                      title=action.capitalize(), items=[{"text": f"{action} for Project {project} reference {700000 + serial}"}],
                      tool="tasks.create")
    return row(split, "task_capture_mode", serial, raw, expected)


def memory_row(split: str, serial: int) -> dict[str, Any]:
    topic, project = ACTIONS[serial % len(ACTIONS)], PROJECTS[(serial // len(ACTIONS)) % len(PROJECTS)]
    normalized = f"What did I save about {topic} for Project {project} reference {710000 + serial}?"
    forms = [normalized, f"Uh, what did I save about {topic} for project {project} reference {710000 + serial}",
             f"Search my saved notes for {topic} in Project {project}, reference {710000 + serial}."]
    raw = forms[serial % len(forms)]
    expected = output(normalized=normalized, mode="query", intent="memory_query", tool="memory.search")
    return row(split, "memory_query_mode", serial, raw, expected)


def reminder_row(split: str, serial: int) -> dict[str, Any]:
    action, project = ACTIONS[serial % len(ACTIONS)], PROJECTS[(serial // len(ACTIONS)) % len(PROJECTS)]
    date, time = DATE_TIME[(serial // (len(ACTIONS) * len(PROJECTS))) % len(DATE_TIME)]
    recipient = PEOPLE[serial % len(PEOPLE)] if serial % 4 == 0 else None
    if recipient:
        normalized = f"Remind me {date} {time} to {recipient} for {action} for Project {project} reference {720000 + serial}."
    else:
        normalized = f"Remind me {date} {time} to {action} for Project {project} reference {720000 + serial}."
    forms = [normalized, "Um okay " + normalized[0].lower() + normalized[1:-1],
             f"Actually, final reminder: {normalized}"]
    raw = forms[serial % len(forms)]
    expected = output(normalized=normalized, mode="capture", intent="reminder",
                      title=action.capitalize(), entity_values=entities(recipient=recipient, date=date, time=time),
                      tool="reminders.propose", confirmation=True)
    return row(split, "grounded_reminder_not_clarify", serial, raw, expected)


def clarify_row(split: str, serial: int) -> dict[str, Any]:
    raw, question = AMBIGUOUS[serial % len(AMBIGUOUS)]
    raw = f"{raw[:-1]} regarding Project {PROJECTS[serial % len(PROJECTS)]} reference {730000 + serial}."
    expected = output(normalized=raw, mode="control", intent="clarify", confirmation=True,
                      question=question, confidence=0.55)
    return row(split, "true_ambiguity_control", serial, raw, expected)


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()]


def fingerprint(row_value: dict[str, Any]) -> str:
    messages = row_value["messages"]
    return hashlib.sha256("\n".join(m["content"] for m in messages).encode()).hexdigest()


def load_replay(path: Path, count: int, split: str, forbidden_users: set[str], forbidden_fps: set[str],
                reserved_users: set[str]) -> list[dict[str, Any]]:
    candidates = []
    seen_candidates = set()
    for source in load_jsonl(path):
        copied = dict(source)
        copied["source"] = "original_sft_replay"
        copied["focus"] = "replay"
        user = copied["messages"][1]["content"]
        if (user not in forbidden_users and user not in reserved_users and user not in seen_candidates
                and fingerprint(copied) not in forbidden_fps):
            candidates.append(copied)
            seen_candidates.add(user)
    if len(candidates) < count:
        raise ValueError(f"Only {len(candidates)} leakage-safe replay rows available for {split}")
    selected = random.Random(SEED + (0 if split == "train" else 1)).sample(candidates, count)
    reserved_users.update(item["messages"][1]["content"] for item in selected)
    return selected


def frozen_fingerprints(root: Path) -> tuple[set[str], set[str]]:
    users, fps = set(), set()
    for name in ("test.jsonl", "challenge.jsonl"):
        for item in load_jsonl(root / name):
            users.add(item["messages"][1]["content"])
            fps.add(fingerprint(item))
    return users, fps


def audit(rows_by_split: dict[str, list[dict[str, Any]]], schema_path: Path,
          forbidden_users: set[str], forbidden_fps: set[str]) -> dict[str, Any]:
    validator = Draft202012Validator(json.loads(schema_path.read_text()))
    ids, fps, users, errors = set(), set(), set(), []
    coverage = {}
    for split, rows in rows_by_split.items():
        counts = Counter()
        for item in rows:
            row_id, user = item["example_id"], item["messages"][1]["content"]
            fp = fingerprint(item)
            if row_id in ids: errors.append(f"duplicate id: {row_id}")
            if fp in fps: errors.append(f"duplicate fingerprint: {row_id}")
            if user in users: errors.append(f"duplicate user prompt: {row_id}")
            if user in forbidden_users or fp in forbidden_fps: errors.append(f"frozen-eval leakage: {row_id}")
            ids.add(row_id); fps.add(fp); users.add(user)
            counts[item.get("focus", "unknown")] += 1
            if item["messages"][0]["content"].startswith("[MODE: ACTION]"):
                try:
                    value = json.loads(item["messages"][2]["content"])
                    schema_errors = list(validator.iter_errors(value))
                    if schema_errors: errors.append(f"schema: {row_id}: {schema_errors[0].message}")
                except Exception as exc:
                    errors.append(f"json: {row_id}: {exc}")
        coverage[split] = dict(sorted(counts.items()))
    return {"passed": not errors, "errors": errors[:100], "total_rows": sum(map(len, rows_by_split.values())),
            "unique_ids": len(ids), "unique_fingerprints": len(fps), "unique_user_prompts": len(users),
            "frozen_eval_user_prompts": len(forbidden_users), "frozen_eval_fingerprints": len(forbidden_fps),
            "coverage": coverage}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--original-root", type=Path, required=True)
    parser.add_argument("--frozen-eval-root", type=Path, required=True)
    parser.add_argument("--schema", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    forbidden_users, forbidden_fps = frozen_fingerprints(args.frozen_eval_root)
    config = {
        "train": (280, 220, 520, 160, 420),
        "validation": (44, 36, 84, 28, 64),
    }
    rows_by_split = {}
    reserved_users: set[str] = set()
    for split, (tasks, memories, reminders, clarifies, replays) in config.items():
        offset = 0 if split == "train" else 100000
        rows = [task_row(split, offset + i) for i in range(tasks)]
        rows += [memory_row(split, offset + i) for i in range(memories)]
        rows += [reminder_row(split, offset + i) for i in range(reminders)]
        rows += [clarify_row(split, offset + i) for i in range(clarifies)]
        reserved_users.update(item["messages"][1]["content"] for item in rows)
        rows += load_replay(args.original_root / "sft" / f"{split}.jsonl", replays, split,
                            forbidden_users, forbidden_fps, reserved_users)
        random.Random(SEED + offset).shuffle(rows)
        rows_by_split[split] = rows
    report = audit(rows_by_split, args.schema, forbidden_users, forbidden_fps)
    if not report["passed"]:
        raise SystemExit(json.dumps(report, indent=2))
    files = {}
    for split, rows in rows_by_split.items():
        path = args.output / f"{split}.jsonl"
        with path.open("w", encoding="utf-8") as handle:
            for item in rows:
                handle.write(compact(item) + "\n")
        files[split] = {"name": path.name, "rows": len(rows), "sha256": sha256(path)}
    audit_path = args.output / "audit_report.json"
    audit_path.write_text(json.dumps(report, indent=2) + "\n")
    manifest = {
        "schema_version": 1, "release_ready": True, "audit_passed": True,
        "dataset_kind": "mode_and_reminder_antiregression_with_original_replay",
        "seed": SEED, "source_adapter_sha256": SOURCE_ADAPTER_SHA256,
        "files": files, "audit": {"name": audit_path.name, "sha256": sha256(audit_path)},
        "training_policy": {"continue_existing_adapter": True, "restart_from_zero": False,
                            "epochs": 1, "learning_rate": 2e-6},
    }
    manifest_path = args.output / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps({"manifest_sha256": sha256(manifest_path), "manifest": manifest, "audit": report}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
