#!/usr/bin/env python3
"""Merge the verified Core v5 LoRA adapter into its Hugging Face base model."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import torch
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--adapter", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--expected-adapter-sha256", required=True)
    args = parser.parse_args()

    weight = args.adapter / "adapter_model.safetensors"
    actual = sha256(weight)
    if actual != args.expected_adapter_sha256:
        raise SystemExit(f"Adapter checksum mismatch: {actual}")

    config = json.loads((args.adapter / "adapter_config.json").read_text())
    base = config["base_model_name_or_path"]
    tokenizer = AutoTokenizer.from_pretrained(args.adapter, trust_remote_code=True)
    model = AutoModelForCausalLM.from_pretrained(
        base,
        torch_dtype=torch.float16,
        low_cpu_mem_usage=True,
        trust_remote_code=True,
    )
    model = PeftModel.from_pretrained(model, args.adapter)
    model = model.merge_and_unload(safe_merge=True)
    args.output.mkdir(parents=True, exist_ok=True)
    model.save_pretrained(args.output, safe_serialization=True, max_shard_size="4GB")
    tokenizer.save_pretrained(args.output)
    (args.output / "merge_manifest.json").write_text(json.dumps({
        "base_model": base,
        "adapter_sha256": actual,
        "merged_dtype": "float16",
        "safe_merge": True,
    }, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
