#!/usr/bin/env python3
"""Merge a QLoRA adapter into the same dequantized NF4 base used in training."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import torch
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(4 * 1024 * 1024), b""):
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
    adapter_config = json.loads((args.adapter / "adapter_config.json").read_text())
    base_name = adapter_config["base_model_name_or_path"]
    quantization = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=torch.float16,
        bnb_4bit_use_double_quant=True,
    )
    tokenizer = AutoTokenizer.from_pretrained(args.adapter, trust_remote_code=True)
    base = AutoModelForCausalLM.from_pretrained(
        base_name,
        quantization_config=quantization,
        device_map={"": "cpu"},
        low_cpu_mem_usage=True,
        trust_remote_code=True,
    )
    base.dequantize()
    model = PeftModel.from_pretrained(base, args.adapter, is_trainable=False)
    model = model.merge_and_unload(safe_merge=True)
    args.output.mkdir(parents=True, exist_ok=False)
    model.save_pretrained(args.output, safe_serialization=True, max_shard_size="4GB")
    tokenizer.save_pretrained(args.output)
    (args.output / "merge_manifest.json").write_text(json.dumps({
        "base_model": base_name,
        "adapter_sha256": actual,
        "merge_base_representation": "dequantized_nf4_double_quant",
        "training_quantization": {
            "load_in_4bit": True,
            "quant_type": "nf4",
            "compute_dtype": "float16",
            "double_quant": True,
        },
        "safe_merge": True,
    }, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
