#!/usr/bin/env python3
"""Evaluate the corrected adapter on frozen correction test and challenge splits."""

from __future__ import annotations

import argparse
import collections
import hashlib
import json
import re
import shutil
import time
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_json(value: str) -> dict | None:
    text = value.strip()
    fence = "`" * 3
    if text.startswith(fence + "json"):
        text = text[len(fence) + 4 :].strip()
    elif text.startswith(fence):
        text = text[len(fence) :].strip()
    if text.endswith(fence):
        text = text[: -len(fence)].strip()
    try:
        result = json.loads(text)
        return result if isinstance(result, dict) else None
    except json.JSONDecodeError:
        return None


def tool_name(value: dict | None) -> str | None:
    tool = value.get("proposed_tool") if isinstance(value, dict) else None
    return tool.get("name") if isinstance(tool, dict) else None


def rates(counter: collections.Counter) -> dict:
    rows = counter["rows"]
    return {key: value if key == "rows" else value / rows for key, value in counter.items()}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--adapter", type=Path, required=True)
    parser.add_argument("--data-dir", type=Path, required=True)
    parser.add_argument("--schema", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--batch-size", type=int, default=12)
    args = parser.parse_args()

    import torch
    import transformers.integrations.tensor_parallel as tensor_parallel

    if not hasattr(tensor_parallel, "EmbeddingParallel"):
        class EmbeddingParallel:
            pass
        tensor_parallel.EmbeddingParallel = EmbeddingParallel

    from jsonschema import Draft202012Validator
    from peft import PeftModel
    from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig

    weight_path = args.adapter / "adapter_model.safetensors"
    adapter_hash = sha256(weight_path)
    print(f"CORRECTED_ADAPTER_SHA256 {adapter_hash}", flush=True)
    validator = Draft202012Validator(json.loads(args.schema.read_text()))

    quantization = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=torch.float16,
        bnb_4bit_use_double_quant=True,
    )
    tokenizer = AutoTokenizer.from_pretrained(args.adapter, trust_remote_code=True)
    if tokenizer.pad_token_id is None:
        tokenizer.pad_token = tokenizer.eos_token
    tokenizer.padding_side = "left"
    base = AutoModelForCausalLM.from_pretrained(
        "Qwen/Qwen3-0.6B",
        quantization_config=quantization,
        device_map={"": 0},
        trust_remote_code=True,
        torch_dtype=torch.float16,
    )
    model = PeftModel.from_pretrained(base, args.adapter, is_trainable=False).eval()

    rows: list[dict] = []
    for split in ("test", "challenge"):
        with (args.data_dir / f"{split}.jsonl").open(encoding="utf-8") as handle:
            for line in handle:
                if line.strip():
                    row = json.loads(line)
                    row["_split"] = split
                    rows.append(row)
    rows.sort(key=lambda row: (
        row["example_id"].rsplit(":", 1)[-1],
        len(row["messages"][-2]["content"]),
    ))

    totals = collections.Counter()
    by_intent: dict[str, collections.Counter] = collections.defaultdict(collections.Counter)
    details: list[dict] = []
    started = time.time()
    fence = "`" * 3

    for start in range(0, len(rows), args.batch_size):
        batch = rows[start : start + args.batch_size]
        prompts = [
            tokenizer.apply_chat_template(
                row["messages"][:-1], tokenize=False, add_generation_prompt=True,
                enable_thinking=False,
            )
            for row in batch
        ]
        encoded = tokenizer(
            prompts, return_tensors="pt", padding=True, truncation=True, max_length=1024,
        ).to("cuda:0")
        with torch.inference_mode():
            output_ids = model.generate(
                **encoded,
                # Use the frozen release ceiling. A target-derived ceiling can
                # truncate an incorrect-but-long generation and misclassify it
                # as a JSON/schema failure instead of a semantic failure.
                max_new_tokens=384,
                do_sample=False,
                use_cache=True,
                pad_token_id=tokenizer.pad_token_id,
                eos_token_id=tokenizer.eos_token_id,
            )
        outputs = tokenizer.batch_decode(
            output_ids[:, encoded["input_ids"].shape[1] :], skip_special_tokens=True,
        )

        for row, output in zip(batch, outputs):
            expected_text = row["messages"][-1]["content"].strip()
            mode = row["example_id"].rsplit(":", 1)[-1]
            intent = "normalize"
            checks = {"no_wrapper": fence not in output and "<think>" not in output}
            if mode == "normalize":
                checks["strict"] = output.strip() == expected_text
                checks["operational"] = checks["strict"]
                checks["schema"] = True
                checks["safety"] = True
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
                checks["safety"] = checks["tool"] and checks["confirmation"] and not (
                    parsed
                    and parsed.get("intent") in {"cancel", "noop", "clarify"}
                    and tool_name(parsed) is not None
                )
                checks["strict"] = parsed == expected and checks["no_wrapper"]
                checks["operational"] = (
                    checks["schema"] and checks["intent"] and checks["tool"]
                    and checks["confirmation"]
                )

            totals["rows"] += 1
            by_intent[intent]["rows"] += 1
            for key, passed in checks.items():
                totals[key] += int(passed)
                by_intent[intent][key] += int(passed)
            details.append({
                "example_id": row["example_id"],
                "split": row["_split"],
                "mode": mode,
                "intent": intent,
                "expected": expected_text,
                "output": output,
                "checks": checks,
            })

        done = start + len(batch)
        if done % 120 == 0 or done == len(rows):
            print(f"EVAL {done}/{len(rows)} strict={totals['strict']}", flush=True)

    report = {
        "adapter_sha256": adapter_hash,
        "rows": len(rows),
        "duration_seconds": time.time() - started,
        "overall": rates(totals),
        "by_intent": {key: rates(value) for key, value in sorted(by_intent.items())},
        "source_splits": ["test", "challenge"],
    }
    args.output_dir.mkdir(parents=True, exist_ok=True)
    (args.output_dir / "behavior_report.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    )
    with (args.output_dir / "behavior_details.jsonl").open("w", encoding="utf-8") as handle:
        for row in details:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")
    (args.output_dir / "corrected_adapter_sha256.txt").write_text(
        f"{adapter_hash}  adapter_model.safetensors\n"
    )
    shutil.copytree(args.adapter, args.output_dir / "Adapter-LoRA-Corrected", dirs_exist_ok=True)
    print("BEHAVIOR_REPORT " + json.dumps(report, sort_keys=True), flush=True)
    print("BEHAVIOR_EVALUATION_COMPLETE", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
