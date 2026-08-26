#!/usr/bin/env python3
"""Post-SFT GRPO using the deterministic Core v5 verifier reward."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def verify_rl_gate(manifest_path: Path, data_dir: Path) -> tuple[dict, dict[str, Path]]:
    manifest = json.loads(manifest_path.read_text())
    if manifest.get("release_ready") is not True or manifest.get("audit_passed") is not True:
        raise RuntimeError("RL refused: manifest is not release-ready and audit-passed")
    paths: dict[str, Path] = {}
    for split in ("train", "validation"):
        entry = manifest.get("rl_files", {}).get(split)
        if not entry:
            raise RuntimeError(f"RL refused: missing manifest entry for {split}")
        path = data_dir / entry["name"]
        if not path.is_file() or sha256(path) != entry["sha256"]:
            raise RuntimeError(f"RL refused: hash mismatch for {split}")
        with path.open() as handle:
            rows = sum(1 for line in handle if line.strip())
        if rows != entry["rows"]:
            raise RuntimeError(f"RL refused: row mismatch for {split}")
        paths[split] = path
    return manifest, paths


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True, help="SFT adapter, merged checkpoint, or base model path")
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--data-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--max-steps", type=int, default=250)
    parser.add_argument("--resume", type=Path)
    parser.add_argument("--seed", type=int, default=3407)
    args = parser.parse_args()
    _, paths = verify_rl_gate(args.manifest, args.data_dir)

    import torch
    from datasets import load_dataset
    from peft import AutoPeftModelForCausalLM
    from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig, set_seed
    from trl import GRPOConfig, GRPOTrainer

    try:
        from reward_core_v5 import grpo_reward
    except ImportError:
        from core_v5.training.reward_core_v5 import grpo_reward

    os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")
    local_rank = int(os.environ.get("LOCAL_RANK", "0"))
    torch.cuda.set_device(local_rank)
    set_seed(args.seed)
    dtype = torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16
    quantization = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=dtype,
        bnb_4bit_use_double_quant=True,
    )
    load_kwargs = {
        "quantization_config": quantization,
        "device_map": {"": local_rank},
        "trust_remote_code": True,
        "torch_dtype": dtype,
    }
    model_path = Path(args.model)
    if (model_path / "adapter_config.json").is_file():
        model = AutoPeftModelForCausalLM.from_pretrained(args.model, is_trainable=True, **load_kwargs)
    else:
        model = AutoModelForCausalLM.from_pretrained(args.model, **load_kwargs)
    model.config.use_cache = False
    tokenizer = AutoTokenizer.from_pretrained(args.model, trust_remote_code=True)
    if tokenizer.pad_token_id is None:
        tokenizer.pad_token = tokenizer.eos_token
    tokenizer.padding_side = "left"

    dataset = load_dataset("json", data_files={key: str(value) for key, value in paths.items()})
    config = GRPOConfig(
        output_dir=str(args.output_dir),
        max_steps=args.max_steps,
        learning_rate=1e-6,
        warmup_ratio=0.05,
        beta=0.02,
        num_generations=4,
        max_prompt_length=512,
        max_completion_length=640,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=2,
        gradient_checkpointing=True,
        save_steps=50,
        logging_steps=1,
        report_to="none",
        use_vllm=False,
        seed=args.seed,
        bf16=dtype == torch.bfloat16,
        fp16=dtype == torch.float16,
        ddp_find_unused_parameters=False,
    )
    trainer = GRPOTrainer(
        model=model,
        reward_funcs=grpo_reward,
        args=config,
        train_dataset=dataset["train"],
        eval_dataset=dataset["validation"],
        processing_class=tokenizer,
    )
    trainer.train(resume_from_checkpoint=str(args.resume) if args.resume else None)
    trainer.save_model(args.output_dir / "final_adapter")
    tokenizer.save_pretrained(args.output_dir / "final_adapter")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
