#!/usr/bin/env python3
"""Behavioral evaluation for Core v5 MLX releases.

Scores transcript normalization and action extraction separately, validates every
action against the frozen schema, and reports exact semantic, grounding, safety,
latency, language, intent, ambiguity, ASR-noise, and code-mixing metrics.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import time
from collections import Counter, defaultdict
from pathlib import Path
from statistics import mean, median
from typing import Any

from jsonschema import Draft202012Validator
from mlx_lm import load
from mlx_lm.generate import batch_generate


ROOT_KEYS = {
    "schema_version", "language", "mode", "normalized_text", "intent", "title",
    "items", "entities", "draft", "proposed_tool", "confidence",
    "requires_confirmation", "clarification_question",
}
SEMANTIC_KEYS = (
    "schema_version", "language", "mode", "normalized_text", "intent", "title",
    "items", "entities", "draft", "requires_confirmation", "clarification_question",
)


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    with path.open(encoding="utf-8") as handle:
        return [json.loads(line) for line in handle if line.strip()]


def parse_json(value: str) -> dict[str, Any] | None:
    text = value.strip()
    if text.startswith("```json"):
        text = text[7:]
    elif text.startswith("```"):
        text = text[3:]
    if text.endswith("```"):
        text = text[:-3]
    try:
        result = json.loads(text.strip())
        return result if isinstance(result, dict) else None
    except json.JSONDecodeError:
        return None


def grounded(candidate: str, raw: str) -> bool:
    clean = lambda value: re.sub(r"[^\w]+", " ", value.casefold()).strip()
    left, right = clean(candidate), clean(raw)
    if not left:
        return False
    if left in right:
        return True
    tokens = set(left.split())
    return bool(tokens) and len(tokens & set(right.split())) / len(tokens) >= 0.8


def grounding_pass(candidate: dict[str, Any], raw: str) -> bool:
    for item in candidate.get("items") or []:
        if not isinstance(item, dict) or not grounded(str(item.get("text", "")), raw):
            return False
    entities = candidate.get("entities") or {}
    if not isinstance(entities, dict):
        return False
    values = [
        entities.get("recipient_query"), entities.get("date_phrase"),
        entities.get("time_phrase"), entities.get("place"), entities.get("subject"),
        *(entities.get("people") or []),
    ]
    return all(not value or grounded(str(value), raw) for value in values)


def percentile(values: list[float], quantile: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    index = min(len(ordered) - 1, math.ceil(quantile * len(ordered)) - 1)
    return ordered[index]


def rates(counter: Counter) -> dict[str, Any]:
    rows = counter["rows"]
    result = {"rows": rows}
    for key, value in sorted(counter.items()):
        if key == "rows" or key.endswith("__eligible"):
            continue
        eligible = counter[f"{key}__eligible"]
        result[key] = round(value / eligible, 6) if eligible else None
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--suite", type=Path, required=True)
    parser.add_argument("--annotations", type=Path, required=True)
    parser.add_argument("--schema", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--max-new-tokens", type=int, default=384)
    parser.add_argument("--limit", type=int)
    parser.add_argument("--intents", nargs="+")
    parser.add_argument("--per-intent-limit", type=int)
    parser.add_argument("--log-every", type=int, default=200)
    args = parser.parse_args()

    rows = load_jsonl(args.suite)
    if args.limit:
        rows = rows[:args.limit]
    annotations = {row["example_id"]: row for row in load_jsonl(args.annotations)}
    if args.intents:
        allowed = set(args.intents)
        filtered = []
        counts: Counter[str] = Counter()
        for row in rows:
            example_id, mode = row["example_id"].rsplit(":", 1)
            intent = annotations[example_id]["gold"]["intent"]
            if mode != "action" or intent not in allowed:
                continue
            if args.per_intent_limit and counts[intent] >= args.per_intent_limit:
                continue
            counts[intent] += 1
            filtered.append(row)
        rows = filtered
    validator = Draft202012Validator(json.loads(args.schema.read_text()))
    model, tokenizer = load(str(args.model))
    # Length-homogeneous batches avoid making short NORMALIZE generations wait
    # for long ACTION JSON completions, without changing any scored example.
    rows.sort(key=lambda row: (
        row["example_id"].rsplit(":", 1)[-1],
        len(row["messages"][-1]["content"]),
    ))

    totals = Counter()
    dimensions: dict[str, defaultdict[str, Counter]] = {
        name: defaultdict(Counter) for name in
        ("mode", "language", "intent", "ambiguity", "code_mixed", "asr_noise")
    }
    failures: list[dict[str, Any]] = []
    batch_seconds: list[float] = []
    generated_tokens = 0
    args.output.parent.mkdir(parents=True, exist_ok=True)
    details_path = args.output.with_suffix(".results.jsonl")
    started = time.perf_counter()

    with details_path.open("w", encoding="utf-8") as details:
        for start in range(0, len(rows), args.batch_size):
            batch = rows[start:start + args.batch_size]
            prompts = []
            for row in batch:
                prompt_messages = row["messages"][:-1]
                prompts.append(tokenizer.apply_chat_template(
                    prompt_messages,
                    tokenize=True,
                    add_generation_prompt=True,
                    enable_thinking=False,
                ))
            target_ceiling = max(
                len(tokenizer.encode(row["messages"][-1]["content"], add_special_tokens=False)) + 16
                for row in batch
            )
            batch_max_tokens = min(args.max_new_tokens, max(48, target_ceiling))
            batch_started = time.perf_counter()
            responses = batch_generate(
                model, tokenizer, prompts, max_tokens=batch_max_tokens,
                prefill_batch_size=len(batch), completion_batch_size=len(batch),
            )
            elapsed = time.perf_counter() - batch_started
            batch_seconds.append(elapsed)

            for row, output in zip(batch, responses.texts):
                example_id, mode = row["example_id"].rsplit(":", 1)
                annotation = annotations[example_id]
                expected_text = row["messages"][-1]["content"]
                clean_output = output.strip()
                generated_tokens += len(tokenizer.encode(output, add_special_tokens=False))
                checks: dict[str, bool] = {
                    "no_wrapper": "```" not in output and "<think>" not in output and "</think>" not in output,
                }
                parsed = None
                if mode == "normalize":
                    checks["exact_output"] = clean_output == expected_text.strip()
                    checks["behavior_pass"] = checks["exact_output"] and checks["no_wrapper"]
                else:
                    expected = json.loads(expected_text)
                    parsed = parse_json(output)
                    checks["valid_json"] = parsed is not None
                    checks["schema_valid"] = parsed is not None and not list(validator.iter_errors(parsed))
                    checks["root_keys_exact"] = parsed is not None and set(parsed) == ROOT_KEYS
                    for key in SEMANTIC_KEYS:
                        checks[f"exact_{key}"] = parsed is not None and parsed.get(key) == expected.get(key)
                    expected_tool_object = expected.get("proposed_tool") or {}
                    actual_tool_object = parsed.get("proposed_tool") if parsed else None
                    if not isinstance(actual_tool_object, dict):
                        actual_tool_object = {}
                    expected_tool = expected_tool_object.get("name")
                    actual_tool = actual_tool_object.get("name")
                    checks["exact_tool"] = parsed is not None and actual_tool == expected_tool
                    checks["exact_tool_arguments"] = parsed is not None and (
                        actual_tool_object.get("arguments")
                        == expected_tool_object.get("arguments")
                    )
                    checks["grounded"] = parsed is not None and grounding_pass(parsed, annotation["raw_transcript"])
                    checks["control_safe"] = parsed is not None and not (
                        parsed.get("intent") in {"cancel", "noop", "clarify"} and actual_tool is not None
                    )
                    checks["exact_json"] = parsed == expected
                    required = [
                        "no_wrapper", "valid_json", "schema_valid", "root_keys_exact",
                        *(f"exact_{key}" for key in SEMANTIC_KEYS),
                        "exact_tool", "exact_tool_arguments", "control_safe",
                    ]
                    checks["behavior_pass"] = all(checks[key] for key in required)

                buckets = [
                    totals,
                    dimensions["mode"][mode],
                    dimensions["language"][annotation["language"]],
                    dimensions["intent"][annotation["gold"]["intent"]],
                    dimensions["ambiguity"][annotation["ambiguity"]],
                    dimensions["code_mixed"][str(bool(annotation["is_code_mixed"])).lower()],
                    dimensions["asr_noise"][str(bool(annotation["asr_tags"])).lower()],
                ]
                for bucket in buckets:
                    bucket["rows"] += 1
                    for key, value in checks.items():
                        bucket[key] += int(value)
                        bucket[f"{key}__eligible"] += 1
                result = {
                    "example_id": row["example_id"], "mode": mode,
                    "expected": expected_text, "output": output, "checks": checks,
                }
                details.write(json.dumps(result, ensure_ascii=False) + "\n")
                if not checks["behavior_pass"] and len(failures) < 100:
                    failures.append(result)

            done = min(start + len(batch), len(rows))
            if done == len(rows) or done % args.log_every < len(batch):
                print(f"[{done}/{len(rows)}] behavior_pass={totals['behavior_pass']}/{totals['rows']}", flush=True)

    duration = time.perf_counter() - started
    report = {
        "model": str(args.model), "suite": str(args.suite), "annotations": str(args.annotations),
        "rows": len(rows), "passed": totals["behavior_pass"] == totals["rows"],
        "failure_count": totals["rows"] - totals["behavior_pass"],
        "overall": rates(totals),
        "by_dimension": {
            name: {key: rates(value) for key, value in sorted(groups.items())}
            for name, groups in dimensions.items()
        },
        "performance": {
            "wall_seconds": round(duration, 3),
            "rows_per_second": round(len(rows) / duration, 3),
            "generated_tokens": generated_tokens,
            "generated_tokens_per_second": round(generated_tokens / duration, 3),
            "batch_seconds_mean": round(mean(batch_seconds), 3),
            "batch_seconds_median": round(median(batch_seconds), 3),
            "batch_seconds_p95": round(percentile(batch_seconds, 0.95), 3),
            "batch_size": args.batch_size,
        },
        "failure_samples_capped_at_100": failures,
        "full_results_jsonl": str(details_path),
    }
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({
        "passed": report["passed"], "failure_count": report["failure_count"],
        "overall": report["overall"], "performance": report["performance"],
    }, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
