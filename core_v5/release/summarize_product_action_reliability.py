#!/usr/bin/env python3
"""Summarize NoteEchoes product-action reliability from Core v5 result rows.

Full-object exactness intentionally includes title wording and language-label
choices. This report measures the fields that change product actions.
"""

from __future__ import annotations

import argparse
import collections
import json
from pathlib import Path
from typing import Any


REQUIRED_CHECKS = (
    "valid_json",
    "schema_valid",
    "exact_intent",
    "exact_items",
    "exact_entities",
    "exact_draft",
    "exact_tool",
    "exact_tool_arguments",
    "exact_requires_confirmation",
    "control_safe",
)
REPORTED_CHECKS = (*REQUIRED_CHECKS, "grounded")


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    with path.open(encoding="utf-8") as handle:
        return [json.loads(line) for line in handle if line.strip()]


def rates(counter: collections.Counter[str]) -> dict[str, Any]:
    rows = counter["rows"]
    return {
        "rows": rows,
        "product_action_pass": round(counter["product_action_pass"] / rows, 6),
        **{
            key: round(counter[key] / rows, 6)
            for key in REPORTED_CHECKS
        },
    }


def speech_style(annotation: dict[str, Any]) -> str:
    raw = annotation["raw_transcript"]
    has_telugu = any("\u0c00" <= char <= "\u0c7f" for char in raw)
    has_hindi = any("\u0900" <= char <= "\u097f" for char in raw)
    has_latin = any(char.isascii() and char.isalpha() for char in raw)
    if has_telugu and has_hindi:
        return "te_hi_en" if has_latin else "te_hi"
    if has_telugu and has_latin:
        return "te_en"
    if has_hindi and has_latin:
        return "hi_en"
    return annotation["language"]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--results", type=Path, required=True)
    parser.add_argument("--annotations", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    annotations = {
        row["example_id"]: row for row in load_jsonl(args.annotations)
    }
    overall: collections.Counter[str] = collections.Counter()
    by_language: dict[str, collections.Counter[str]] = collections.defaultdict(
        collections.Counter
    )
    by_intent: dict[str, collections.Counter[str]] = collections.defaultdict(
        collections.Counter
    )
    by_code_mixed: dict[str, collections.Counter[str]] = collections.defaultdict(
        collections.Counter
    )
    by_speech_style: dict[str, collections.Counter[str]] = collections.defaultdict(
        collections.Counter
    )
    by_style_and_intent: dict[str, collections.Counter[str]] = collections.defaultdict(
        collections.Counter
    )
    failures: list[dict[str, Any]] = []

    for row in load_jsonl(args.results):
        example_id = row["example_id"].rsplit(":", 1)[0]
        annotation = annotations[example_id]
        checks = row["checks"]
        passed = all(checks.get(key) is True for key in REQUIRED_CHECKS)
        buckets = (
            overall,
            by_language[annotation["language"]],
            by_intent[annotation["gold"]["intent"]],
            by_code_mixed[str(bool(annotation["is_code_mixed"])).lower()],
            by_speech_style[speech_style(annotation)],
            by_style_and_intent[
                f"{speech_style(annotation)}:{annotation['gold']['intent']}"
            ],
        )
        for bucket in buckets:
            bucket["rows"] += 1
            bucket["product_action_pass"] += int(passed)
            for key in REPORTED_CHECKS:
                bucket[key] += int(checks.get(key) is True)
        if not passed:
            failures.append(
                {
                    "example_id": row["example_id"],
                    "language": annotation["language"],
                    "intent": annotation["gold"]["intent"],
                    "failed_checks": [
                        key for key in REQUIRED_CHECKS if checks.get(key) is not True
                    ],
                }
            )

    report = {
        "metric_definition": {
            "product_action_pass_requires": list(REQUIRED_CHECKS),
            "diagnostic_only": ["grounded"],
            "excludes_non_action_differences": [
                "title wording or capitalization",
                "language label",
                "normalized transcript exact wording",
                "confidence formatting",
            ],
        },
        "overall": rates(overall),
        "by_language": {
            key: rates(value) for key, value in sorted(by_language.items())
        },
        "by_intent": {
            key: rates(value) for key, value in sorted(by_intent.items())
        },
        "by_code_mixed": {
            key: rates(value) for key, value in sorted(by_code_mixed.items())
        },
        "by_speech_style": {
            key: rates(value) for key, value in sorted(by_speech_style.items())
        },
        "by_speech_style_and_intent": {
            key: rates(value) for key, value in sorted(by_style_and_intent.items())
        },
        "failures": failures,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report["overall"], indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
