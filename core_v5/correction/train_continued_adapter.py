#!/usr/bin/env python3
"""Continue the verified Core v5 adapter on the audited correction corpus."""

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


def verify(manifest_path: Path, data_dir: Path, adapter: Path, expected_adapter_sha256: str) -> dict:
    manifest = json.loads(manifest_path.read_text())
    if manifest.get("release_ready") is not True or manifest.get("audit_passed") is not True:
        raise SystemExit("Correction dataset is not release-ready and audit-passed.")
    if manifest.get("training_policy", {}).get("continue_existing_adapter") is not True:
        raise SystemExit("Manifest does not authorize adapter continuation.")
    if manifest.get("source_adapter_sha256") != expected_adapter_sha256:
        raise SystemExit("Manifest source-adapter hash mismatch.")
    adapter_weight = adapter / "adapter_model.safetensors"
    if sha256(adapter_weight) != expected_adapter_sha256:
        raise SystemExit("Adapter weight checksum mismatch.")
    for split, entry in manifest["files"].items():
        path = data_dir / entry["name"]
        if not path.is_file() or sha256(path) != entry["sha256"]:
            raise SystemExit(f"Dataset hash mismatch: {split}")
        rows = sum(1 for line in path.open(encoding="utf-8") if line.strip())
        if rows != entry["rows"]:
            raise SystemExit(f"Dataset row mismatch: {split}")
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--data-dir", type=Path, required=True)
    parser.add_argument("--adapter", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, default=Path("/kaggle/working/noteechoes-english-action-correction"))
    parser.add_argument("--expected-adapter-sha256", required=True)
    parser.add_argument("--seed", type=int, default=3407)
    args = parser.parse_args()
    manifest = verify(args.manifest, args.data_dir, args.adapter, args.expected_adapter_sha256)
    learning_rate = float(manifest.get("training_policy", {}).get("learning_rate", 5e-6))

    import torch
    import transformers.integrations.tensor_parallel as tensor_parallel
    if not hasattr(tensor_parallel, "EmbeddingParallel"):
        class EmbeddingParallel:
            pass
        tensor_parallel.EmbeddingParallel = EmbeddingParallel

    from datasets import load_dataset
    from peft import PeftModel, prepare_model_for_kbit_training
    from transformers import (
        AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig, DataCollatorForSeq2Seq,
        Trainer, TrainingArguments, set_seed,
    )

    os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")
    local_rank = int(os.environ.get("LOCAL_RANK", "0"))
    torch.cuda.set_device(local_rank)
    set_seed(args.seed)
    base_model = "Qwen/Qwen3-0.6B"
    tokenizer = AutoTokenizer.from_pretrained(args.adapter, trust_remote_code=True)
    if tokenizer.pad_token_id is None:
        tokenizer.pad_token = tokenizer.eos_token
    tokenizer.padding_side = "right"
    compute_dtype = torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16
    quantization = BitsAndBytesConfig(
        load_in_4bit=True, bnb_4bit_quant_type="nf4", bnb_4bit_compute_dtype=compute_dtype,
        bnb_4bit_use_double_quant=True,
    )
    model = AutoModelForCausalLM.from_pretrained(
        base_model, quantization_config=quantization, device_map={"": local_rank},
        trust_remote_code=True, torch_dtype=compute_dtype,
    )
    model.config.use_cache = False
    model = prepare_model_for_kbit_training(model, use_gradient_checkpointing=True)
    model = PeftModel.from_pretrained(model, args.adapter, is_trainable=True)
    model.enable_input_require_grads()

    files = {split: str(args.data_dir / manifest["files"][split]["name"]) for split in ("train", "validation")}
    dataset = load_dataset("json", data_files=files)

    def tokenize_completion_only(example):
        messages = example["messages"]
        full_text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=False)
        prompt_text = tokenizer.apply_chat_template(messages[:-1], tokenize=False, add_generation_prompt=True)
        encoded = tokenizer(full_text, truncation=True, max_length=1024, add_special_tokens=False)
        prompt_ids = tokenizer(prompt_text, truncation=True, max_length=1024, add_special_tokens=False)["input_ids"]
        labels = list(encoded["input_ids"])
        masked = min(len(prompt_ids), len(labels))
        labels[:masked] = [-100] * masked
        if not any(label != -100 for label in labels):
            raise ValueError(f"Assistant completion fully truncated: {example.get('example_id')}")
        encoded["labels"] = labels
        return encoded

    tokenized = dataset.map(
        tokenize_completion_only, remove_columns=dataset["train"].column_names,
        num_proc=2, desc="Correction completion-only tokenization",
    )
    training_args = TrainingArguments(
        output_dir=str(args.output_dir), num_train_epochs=1,
        per_device_train_batch_size=8, per_device_eval_batch_size=8,
        gradient_accumulation_steps=2, learning_rate=learning_rate, warmup_ratio=0.1,
        weight_decay=0.01, lr_scheduler_type="cosine", optim="paged_adamw_8bit",
        eval_strategy="steps", save_strategy="steps", eval_steps=25, save_steps=25,
        logging_steps=10, save_total_limit=2, load_best_model_at_end=False,
        ddp_find_unused_parameters=False, seed=args.seed, data_seed=args.seed,
        bf16=torch.cuda.is_bf16_supported(), fp16=not torch.cuda.is_bf16_supported(),
        gradient_checkpointing=True, max_grad_norm=0.3, report_to="none",
        dataloader_num_workers=2,
    )
    trainer = Trainer(
        model=model, args=training_args, train_dataset=tokenized["train"],
        eval_dataset=tokenized["validation"],
        data_collator=DataCollatorForSeq2Seq(tokenizer=tokenizer, padding=True, label_pad_token_id=-100),
    )
    train_result = trainer.train()
    metrics = trainer.evaluate()
    final_dir = args.output_dir / "adapter-final"
    trainer.save_model(str(final_dir))
    tokenizer.save_pretrained(str(final_dir))
    if trainer.is_world_process_zero():
        (args.output_dir / "run_manifest.json").write_text(json.dumps({
            "base_model": base_model,
            "source_adapter_sha256": args.expected_adapter_sha256,
            "correction_manifest_sha256": sha256(args.manifest),
            "continued_from_existing_adapter": True,
            "restart_from_zero": False,
            "seed": args.seed,
            "learning_rate": learning_rate,
            "epochs": 1,
            "train_metrics": train_result.metrics,
            "evaluation_metrics": metrics,
        }, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
