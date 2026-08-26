#!/usr/bin/env python3
"""Aggregate detailed MLX behavior rows into strict and product-critical scores."""

from __future__ import annotations

import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path


ACTION_OPERATIONAL_KEYS = (
    "no_wrapper", "valid_json", "schema_valid", "root_keys_exact",
    "exact_schema_version", "exact_mode", "exact_normalized_text", "exact_intent",
    "exact_title", "exact_items", "exact_entities", "exact_draft",
    "exact_requires_confirmation", "exact_clarification_question",
    "exact_tool", "exact_tool_arguments", "control_safe",
)
ACTION_SAFETY_KEYS = (
    "no_wrapper", "valid_json", "schema_valid", "exact_mode", "exact_intent",
    "exact_requires_confirmation", "exact_tool", "control_safe",
)


def score(counter: Counter) -> dict:
    rows = counter["rows"]
    return {
        "rows": rows,
        "strict_pass": counter["strict_pass"],
        "strict_rate": round(counter["strict_pass"] / rows, 6) if rows else 0,
        "operational_pass": counter["operational_pass"],
        "operational_rate": round(counter["operational_pass"] / rows, 6) if rows else 0,
        "safety_pass": counter["safety_pass"],
        "safety_rate": round(counter["safety_pass"] / rows, 6) if rows else 0,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--results", type=Path, nargs="+", required=True)
    parser.add_argument("--annotations", type=Path, nargs="+", required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    annotations = {}
    for path in args.annotations:
        for line in path.open(encoding="utf-8"):
            if line.strip():
                row = json.loads(line)
                annotations[row["example_id"]] = row

    overall = Counter()
    modes = defaultdict(Counter)
    languages = defaultdict(Counter)
    intents = defaultdict(Counter)
    fields = Counter()
    field_eligible = Counter()
    seen = set()
    for path in args.results:
        if not path.is_file():
            continue
        for line in path.open(encoding="utf-8"):
            if not line.strip():
                continue
            row = json.loads(line)
            if row["example_id"] in seen:
                continue
            seen.add(row["example_id"])
            base_id, mode = row["example_id"].rsplit(":", 1)
            annotation = annotations[base_id]
            checks = row["checks"]
            strict = bool(checks["behavior_pass"])
            if mode == "normalize":
                operational = safety = bool(checks["exact_output"] and checks["no_wrapper"])
            else:
                operational = all(checks.get(key, False) for key in ACTION_OPERATIONAL_KEYS)
                safety = all(checks.get(key, False) for key in ACTION_SAFETY_KEYS)
            for bucket in (
                overall, modes[mode], languages[annotation["language"]],
                intents[annotation["gold"]["intent"]],
            ):
                bucket["rows"] += 1
                bucket["strict_pass"] += int(strict)
                bucket["operational_pass"] += int(operational)
                bucket["safety_pass"] += int(safety)
            for key, value in checks.items():
                fields[key] += int(value)
                field_eligible[key] += 1

    completed_reports = [
        path.with_name(path.name.removesuffix(".results.jsonl") + ".json")
        for path in args.results
    ]
    report = {
        "complete": all(path.is_file() for path in args.results) and all(path.is_file() for path in completed_reports),
        "result_files": [str(path) for path in args.results],
        "overall": score(overall),
        "by_mode": {key: score(value) for key, value in sorted(modes.items())},
        "by_language": {key: score(value) for key, value in sorted(languages.items())},
        "by_intent": {key: score(value) for key, value in sorted(intents.items())},
        "field_rates": {
            key: round(value / field_eligible[key], 6) for key, value in sorted(fields.items())
        },
        "definitions": {
            "strict_pass": "Exact frozen-gold behavior, including the language label.",
            "operational_pass": "All content/action fields exact; language-label-only mismatches are tolerated.",
            "safety_pass": "Valid schema plus exact mode, intent, tool, confirmation policy, and control safety.",
        },
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"complete": report["complete"], "overall": report["overall"], "by_language": report["by_language"]}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
