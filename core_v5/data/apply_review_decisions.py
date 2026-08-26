#!/usr/bin/env python3
"""Apply attributable human decisions while preserving correction history."""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import Counter
from datetime import datetime
from pathlib import Path


def digest(value: object) -> str:
    payload = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--decisions", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    rows = {row["example_id"]: row for row in map(json.loads, args.input.read_text(encoding="utf-8").splitlines())}
    seen: set[str] = set()
    for line_no, line in enumerate(args.decisions.read_text(encoding="utf-8").splitlines(), 1):
        decision = json.loads(line)
        example_id = decision.get("example_id")
        if example_id not in rows or example_id in seen:
            raise SystemExit(f"Decision line {line_no}: unknown or duplicate example_id")
        seen.add(example_id)
        status = decision.get("status")
        if status not in {"approved", "needs_changes", "rejected"}:
            raise SystemExit(f"Decision line {line_no}: invalid status")
        reviewer = str(decision.get("reviewer_id") or "").strip()
        reviewed_at = str(decision.get("reviewed_at") or "").strip()
        if not reviewer or not reviewed_at:
            raise SystemExit(f"Decision line {line_no}: reviewer_id and reviewed_at are required")
        try:
            datetime.fromisoformat(reviewed_at.replace("Z", "+00:00"))
        except ValueError as exc:
            raise SystemExit(f"Decision line {line_no}: invalid timestamp") from exc
        row = rows[example_id]
        old_hash = digest({"gold": row["gold"], "grounding_spans": row["grounding_spans"]})
        if "gold" in decision:
            row["gold"] = decision["gold"]
        if "grounding_spans" in decision:
            row["grounding_spans"] = decision["grounding_spans"]
        native_verified = decision.get("native_language_verified") is True
        if status == "approved" and row["language"] in {"hi", "te", "hi-roman", "te-roman", "mixed"} and not native_verified:
            raise SystemExit(f"Decision line {line_no}: multilingual approval requires native_language_verified=true")
        row["review"] = {
            "status": status, "reviewer_id": reviewer, "reviewed_at": reviewed_at,
            "native_language_verified": native_verified,
        }
        row["history"].append({
            "event": "human_review", "reviewer_id": reviewer, "reviewed_at": reviewed_at,
            "status": status, "before_hash": old_hash,
            "after_hash": digest({"gold": row["gold"], "grounding_spans": row["grounding_spans"]}),
            "notes": decision.get("notes"),
        })
    args.output.parent.mkdir(parents=True, exist_ok=True)
    ordered = sorted(rows.values(), key=lambda row: row["example_id"])
    args.output.write_text("".join(json.dumps(row, ensure_ascii=False, separators=(",", ":")) + "\n" for row in ordered), encoding="utf-8")
    counts = Counter(row["review"]["status"] for row in ordered)
    print(json.dumps({"rows": len(ordered), "decisions_applied": len(seen), "review_counts": counts, "sha256": hashlib.sha256(args.output.read_bytes()).hexdigest()}, default=dict, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
