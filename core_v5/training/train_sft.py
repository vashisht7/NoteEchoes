#!/usr/bin/env python3
"""Checkpointed, completion-only Core v5 QLoRA training for Kaggle."""

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


def verify_file(root: Path, entry: dict, label: str) -> Path:
    path = root / entry["name"]
    if not path.is_file() or sha256(path) != entry.get("sha256"):
        raise SystemExit(f"Refusing to train: {label} hash mismatch.")
    rows = sum(1 for line in path.open(encoding="utf-8") if line.strip())
    if rows != entry.get("rows"):
        raise SystemExit(f"Refusing to train: {label} row-count mismatch.")
    return path


def verify_gate(manifest_path: Path, data_dir: Path) -> tuple[dict, dict[str, Path]]:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("release_ready") is not True or manifest.get("audit_passed") is not True:
        raise SystemExit("Refusing to train: manifest is not release-ready and audit-passed.")
    if manifest.get("review_policy") not in {"named_human_review", "synthetic_waiver_user_authorized_2026-08-24"}:
        raise SystemExit("Refusing to train: unsupported review policy.")
    targets = {"train": 30000, "validation": 2400, "test": 2400, "challenge": 1200}
    for split, expected in targets.items():
        entry = manifest["annotation_files"][split]
        if entry.get("rows") != expected:
            raise SystemExit(f"Refusing to train: {split} annotation count must be {expected}.")
        verify_file(data_dir, entry, f"annotations:{split}")
    paths = {split: verify_file(data_dir, manifest["files"][split], f"sft:{split}") for split in ("train", "validation")}
    return manifest, paths


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True, choices=["Qwen/Qwen3-0.6B", "Qwen/Qwen3.5-0.8B"])
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--data-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, default=Path("/kaggle/working/core-v5"))
    parser.add_argument("--resume", type=Path)
    parser.add_argument("--seed", type=int, default=3407)
    args = parser.parse_args()
    manifest, paths = verify_gate(args.manifest, args.data_dir)

    import torch
    from datasets import load_dataset
    from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
    from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig, DataCollatorForSeq2Seq, Trainer, TrainingArguments, set_seed

    os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")
    local_rank = int(os.environ.get("LOCAL_RANK", "0"))
    torch.cuda.set_device(local_rank)
    set_seed(args.seed)
    tokenizer = AutoTokenizer.from_pretrained(args.model, trust_remote_code=True)
    if tokenizer.pad_token_id is None: tokenizer.pad_token = tokenizer.eos_token
    tokenizer.padding_side = "right"
    compute_dtype = torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16
    quantization = BitsAndBytesConfig(load_in_4bit=True, bnb_4bit_quant_type="nf4", bnb_4bit_compute_dtype=compute_dtype, bnb_4bit_use_double_quant=True)
    model = AutoModelForCausalLM.from_pretrained(
        args.model,
        quantization_config=quantization,
        device_map={"": local_rank},
        trust_remote_code=True,
        torch_dtype=compute_dtype,
    )
    model.config.use_cache = False
    model = prepare_model_for_kbit_training(model, use_gradient_checkpointing=True)
    model = get_peft_model(model, LoraConfig(
        r=32, lora_alpha=64, lora_dropout=0.05, use_rslora=True, bias="none", task_type="CAUSAL_LM",
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
    ))
    dataset = load_dataset("json", data_files={key: str(value) for key, value in paths.items()})

    def tokenize_completion_only(example):
        messages = example["messages"]
        full_text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=False)
        prompt_text = tokenizer.apply_chat_template(messages[:-1], tokenize=False, add_generation_prompt=True)
        encoded = tokenizer(full_text, truncation=True, max_length=1024, add_special_tokens=False)
        prompt_ids = tokenizer(prompt_text, truncation=True, max_length=1024, add_special_tokens=False)["input_ids"]
        labels = list(encoded["input_ids"])
        labels[:min(len(prompt_ids), len(labels))] = [-100] * min(len(prompt_ids), len(labels))
        if not any(label != -100 for label in labels): raise ValueError(f"Assistant completion fully truncated: {example.get('example_id')}")
        encoded["labels"] = labels
        return encoded

    tokenized = dataset.map(tokenize_completion_only, remove_columns=dataset["train"].column_names, num_proc=2, desc="Completion-only tokenization")
    training_args = TrainingArguments(
        output_dir=str(args.output_dir), num_train_epochs=1, per_device_train_batch_size=8, per_device_eval_batch_size=8,
        gradient_accumulation_steps=2, learning_rate=4e-5, warmup_ratio=0.05, weight_decay=0.01,
        lr_scheduler_type="cosine", optim="paged_adamw_8bit", eval_strategy="steps", save_strategy="steps",
        ddp_find_unused_parameters=False,
        eval_steps=250, save_steps=250, logging_steps=25, save_total_limit=3, load_best_model_at_end=False,
        metric_for_best_model="eval_loss", greater_is_better=False, seed=args.seed, data_seed=args.seed,
        bf16=torch.cuda.is_bf16_supported(), fp16=not torch.cuda.is_bf16_supported(), gradient_checkpointing=True,
        report_to="none", dataloader_num_workers=2,
    )
    trainer = Trainer(
        model=model, args=training_args, train_dataset=tokenized["train"], eval_dataset=tokenized["validation"],
        data_collator=DataCollatorForSeq2Seq(tokenizer=tokenizer, padding=True, label_pad_token_id=-100),
    )
    trainer.train(resume_from_checkpoint=str(args.resume) if args.resume else None)
    final_dir = args.output_dir / "adapter-final"
    trainer.save_model(str(final_dir)); tokenizer.save_pretrained(str(final_dir))
    (args.output_dir / "run_manifest.json").write_text(json.dumps({
        "dataset_manifest_sha256": sha256(args.manifest), "model": args.model, "seed": args.seed,
        "completion_only_masking": True, "review_policy": manifest["review_policy"],
    }, indent=2) + "\n")
    return 0


if __name__ == "__main__": raise SystemExit(main())
