#!/usr/bin/env python3
"""Build a deterministic 300-case draft probe without pretending it was reviewed."""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import defaultdict, deque
from pathlib import Path


def family(row: dict) -> str | None:
    language = row["language"]
    script = row["script"]
    if language == "en":
        return "english"
    if language in {"hi", "hi-roman"} or (language == "mixed" and script in {"devanagari", "mixed"} and any("\u0900" <= c <= "\u097f" for c in row["raw_transcript"])):
        return "hindi"
    if language in {"te", "te-roman"} or (language == "mixed" and any("\u0c00" <= c <= "\u0c7f" for c in row["raw_transcript"])):
        return "telugu"
    return None


def pick_balanced(rows: list[dict], group: str, count: int) -> list[dict]:
    buckets: dict[str, deque[dict]] = defaultdict(deque)
    for row in sorted((r for r in rows if family(r) == group), key=lambda r: r["example_id"]):
        if "legacy_multi_action_requires_reannotation" not in row["safety_tags"]:
            buckets[row["gold"]["intent"]].append(row)
    selected: list[dict] = []
    intents = sorted(buckets)
    while len(selected) < count and intents:
        next_intents: list[str] = []
        for intent in intents:
            if buckets[intent] and len(selected) < count:
                selected.append(buckets[intent].popleft())
            if buckets[intent]:
                next_intents.append(intent)
        intents = next_intents
    if len(selected) != count:
        raise RuntimeError(f"Only found {len(selected)} usable {group} rows")
    return selected


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--staging", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    rows = [json.loads(line) for line in args.staging.read_text(encoding="utf-8").splitlines()]
    selected = []
    for group in ("english", "hindi", "telugu"):
        selected.extend({"probe_group": group, **row} for row in pick_balanced(rows, group, 100))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("".join(json.dumps(row, ensure_ascii=False, separators=(",", ":")) + "\n" for row in selected), encoding="utf-8")
    digest = hashlib.sha256(args.output.read_bytes()).hexdigest()
    manifest = {
        "status": "draft_not_frozen",
        "rows": len(selected),
        "groups": {name: sum(row["probe_group"] == name for row in selected) for name in ("english", "hindi", "telugu")},
        "sha256": digest,
        "freeze_requirements": [
            "review every full Core v5 label and grounding span",
            "native Hindi reviewer approval for all Hindi cases",
            "native Telugu reviewer approval for all Telugu cases",
            "record reviewer IDs and timestamps, then regenerate the signed manifest"
        ],
    }
    manifest_path = args.output.with_suffix(".manifest.json")
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
