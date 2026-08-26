#!/usr/bin/env python3
"""Run the frozen correction release evaluation against an MLX model.

This mirrors the Kaggle PEFT evaluator's fixed 384-token generation ceiling and
operational release criteria so an 8-bit conversion is tested without changing
the frozen 1,200-row test/challenge suite.
"""

from __future__ import annotations

import argparse
import collections
import json
import time
from pathlib import Path

from jsonschema import Draft202012Validator
from mlx_lm import load
from mlx_lm.generate import batch_generate


ACTION_METRICS = (
    "json_valid", "schema", "intent", "tool", "confirmation", "safety",
)
ALL_METRICS = ("no_wrapper", "strict", "operational")


def load_jsonl(path: Path) -> list[dict]:
    with path.open(encoding="utf-8") as handle:
        return [json.loads(line) for line in handle if line.strip()]


def parse_json(value: str) -> dict | None:
    text = value.strip()
    if text.startswith("```json"):
        text = text[7:].strip()
    elif text.startswith("```"):
        text = text[3:].strip()
    if text.endswith("```"):
        text = text[:-3].strip()
    try:
        result = json.loads(text)
        return result if isinstance(result, dict) else None
    except json.JSONDecodeError:
        return None


def tool_name(value: dict | None) -> str | None:
    tool = value.get("proposed_tool") if isinstance(value, dict) else None
    return tool.get("name") if isinstance(tool, dict) else None


def metric_rates(counter: collections.Counter) -> dict:
    result = {"rows": counter["rows"]}
    for metric in (*ALL_METRICS, *ACTION_METRICS):
        eligible = counter[f"{metric}__eligible"]
        if eligible:
            result[metric] = counter[metric] / eligible
            result[f"{metric}_eligible_rows"] = eligible
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--data-dir", type=Path, required=True)
    parser.add_argument("--schema", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--batch-size", type=int, default=12)
    parser.add_argument("--max-new-tokens", type=int, default=384)
    parser.add_argument("--limit", type=int)
    parser.add_argument(
        "--example-ids-file", type=Path,
        help="Optional newline-delimited example IDs for targeted regression checks.",
    )
    parser.add_argument(
        "--failed-results", type=Path,
        help="Optional prior behavior_details JSONL; rerun only operational failures.",
    )
    parser.add_argument("--log-every", type=int, default=120)
    args = parser.parse_args()

    validator = Draft202012Validator(json.loads(args.schema.read_text()))
    model, tokenizer = load(str(args.model))
    rows: list[dict] = []
    for split in ("test", "challenge"):
        for row in load_jsonl(args.data_dir / f"{split}.jsonl"):
            row["_split"] = split
            rows.append(row)
    rows.sort(key=lambda row: (
        row["example_id"].rsplit(":", 1)[-1],
        len(row["messages"][-2]["content"]),
    ))
    requested: set[str] | None = None
    if args.example_ids_file:
        requested = {
            line.strip() for line in args.example_ids_file.read_text().splitlines()
            if line.strip()
        }
    if args.failed_results:
        failed = {
            row["example_id"] for row in load_jsonl(args.failed_results)
            if not row.get("checks", {}).get("operational", False)
        }
        requested = failed if requested is None else requested & failed
    if requested is not None:
        rows = [row for row in rows if row["example_id"] in requested]
        found = {row["example_id"] for row in rows}
        missing = requested - found
        if missing:
            raise ValueError(f"Unknown example IDs: {sorted(missing)}")
    if args.limit:
        rows = rows[:args.limit]

    totals = collections.Counter()
    by_intent: dict[str, collections.Counter] = collections.defaultdict(collections.Counter)
    by_split: dict[str, collections.Counter] = collections.defaultdict(collections.Counter)
    details: list[dict] = []
    started = time.perf_counter()

    for start in range(0, len(rows), args.batch_size):
        batch = rows[start : start + args.batch_size]
        prompts = [
            tokenizer.apply_chat_template(
                row["messages"][:-1], tokenize=True, add_generation_prompt=True,
                enable_thinking=False,
            )
            for row in batch
        ]
        responses = batch_generate(
            model, tokenizer, prompts, max_tokens=args.max_new_tokens,
            prefill_batch_size=len(batch), completion_batch_size=len(batch),
        )

        for row, output in zip(batch, responses.texts):
            expected_text = row["messages"][-1]["content"].strip()
            mode = row["example_id"].rsplit(":", 1)[-1]
            intent = "normalize"
            checks = {
                "no_wrapper": "```" not in output and "<think>" not in output,
            }
            eligible = set(ALL_METRICS)
            if mode == "normalize":
                checks["strict"] = output.strip() == expected_text
                checks["operational"] = checks["strict"] and checks["no_wrapper"]
            else:
                expected = json.loads(expected_text)
                intent = expected["intent"]
                parsed = parse_json(output)
                checks["json_valid"] = parsed is not None
                checks["schema"] = parsed is not None and not list(validator.iter_errors(parsed))
                checks["intent"] = parsed is not None and parsed.get("intent") == expected.get("intent")
                checks["tool"] = parsed is not None and tool_name(parsed) == tool_name(expected)
                checks["confirmation"] = (
                    parsed is not None
                    and parsed.get("requires_confirmation") == expected.get("requires_confirmation")
                )
                controls_safe = not (
                    parsed
                    and parsed.get("intent") in {"cancel", "noop", "clarify"}
                    and tool_name(parsed) is not None
                )
                checks["safety"] = checks["tool"] and checks["confirmation"] and controls_safe
                checks["strict"] = parsed == expected and checks["no_wrapper"]
                checks["operational"] = (
                    checks["no_wrapper"] and checks["schema"] and checks["intent"]
                    and checks["tool"] and checks["confirmation"] and checks["safety"]
                )
                eligible.update(ACTION_METRICS)

            buckets = (totals, by_intent[intent], by_split[row["_split"]])
            for bucket in buckets:
                bucket["rows"] += 1
                for metric in eligible:
                    bucket[f"{metric}__eligible"] += 1
                    bucket[metric] += int(checks[metric])
            details.append({
                "example_id": row["example_id"], "split": row["_split"],
                "mode": mode, "intent": intent, "expected": expected_text,
                "output": output, "checks": checks,
            })

        done = start + len(batch)
        if done == len(rows) or done % args.log_every < len(batch):
            print(
                f"MLX_EVAL {done}/{len(rows)} operational="
                f"{totals['operational']}/{totals['operational__eligible']}",
                flush=True,
            )

    duration = time.perf_counter() - started
    overall = metric_rates(totals)
    release_gates = {
        "operational_100_percent": overall.get("operational") == 1.0,
        "json_100_percent": overall.get("json_valid") == 1.0,
        "schema_100_percent": overall.get("schema") == 1.0,
        "safety_100_percent": overall.get("safety") == 1.0,
    }
    report = {
        "model": str(args.model), "rows": len(rows),
        "max_new_tokens": args.max_new_tokens,
        "duration_seconds": duration,
        "overall": overall,
        "by_intent": {key: metric_rates(value) for key, value in sorted(by_intent.items())},
        "by_split": {key: metric_rates(value) for key, value in sorted(by_split.items())},
        "release_gates": release_gates,
        "passed": all(release_gates.values()),
        "source_splits": ["test", "challenge"],
    }
    args.output_dir.mkdir(parents=True, exist_ok=True)
    (args.output_dir / "behavior_report.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    )
    with (args.output_dir / "behavior_details.jsonl").open("w", encoding="utf-8") as handle:
        for row in details:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")
    print("MLX_BEHAVIOR_REPORT " + json.dumps(report, sort_keys=True), flush=True)
    return 0 if report["passed"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
