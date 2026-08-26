#!/usr/bin/env python3
"""Measure how often frozen gold fields are directly recoverable from raw speech."""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path


def grounded(candidate: str, raw: str) -> bool:
    clean = lambda value: re.sub(r"[^\w]+", " ", value.casefold()).strip()
    left, right = clean(candidate), clean(raw)
    if not left:
        return False
    if left in right:
        return True
    tokens = set(left.split())
    return bool(tokens) and len(tokens & set(right.split())) / len(tokens) >= 0.8


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--annotations", type=Path, nargs="+", required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    totals = Counter()
    failures = []
    for path in args.annotations:
        for line in path.open(encoding="utf-8"):
            if not line.strip():
                continue
            row = json.loads(line)
            entities = row["gold"]["entities"]
            values = {
                "recipient_query": entities.get("recipient_query"),
                "date_phrase": entities.get("date_phrase"),
                "time_phrase": entities.get("time_phrase"),
                "place": entities.get("place"),
                "subject": entities.get("subject"),
            }
            for index, value in enumerate(entities.get("people") or []):
                values[f"people[{index}]"] = value
            for index, item in enumerate(row["gold"].get("items") or []):
                values[f"items[{index}]"] = item.get("text")
            row_ok = True
            for field, value in values.items():
                if not value:
                    continue
                ok = grounded(str(value), row["raw_transcript"])
                totals["fields"] += 1
                totals["grounded_fields"] += int(ok)
                row_ok &= ok
                if not ok and len(failures) < 100:
                    failures.append({
                        "example_id": row["example_id"], "field": field,
                        "gold_value": value, "raw_transcript": row["raw_transcript"],
                        "asr_tags": row["asr_tags"],
                    })
            totals["rows"] += 1
            totals["fully_grounded_rows"] += int(row_ok)
    report = {
        "rows": totals["rows"], "fields": totals["fields"],
        "fully_grounded_rows": totals["fully_grounded_rows"],
        "fully_grounded_row_rate": round(totals["fully_grounded_rows"] / totals["rows"], 6),
        "grounded_fields": totals["grounded_fields"],
        "grounded_field_rate": round(totals["grounded_fields"] / totals["fields"], 6),
        "interpretation": "Diagnostic only: normalized ASR corrections can legitimately differ from the raw transcript.",
        "failure_samples_capped_at_100": failures,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({key: report[key] for key in report if key != "failure_samples_capped_at_100"}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
