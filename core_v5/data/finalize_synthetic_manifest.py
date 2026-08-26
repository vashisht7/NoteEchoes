#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(); parser.add_argument("--root", type=Path, required=True); args = parser.parse_args()
    generation = json.loads((args.root / "generation_report.json").read_text()); audit_path = args.root / "audit_report.json"; audit = json.loads(audit_path.read_text())
    if not audit.get("passed") or not audit.get("experimental_synthetic_release"): raise SystemExit("Cannot finalize: synthetic audit did not pass.")
    source = generation["files"]
    manifest = {
        "schema_version": 1, "release_ready": True, "audit_passed": True, "release_kind": "experimental_synthetic",
        "created_at": "2026-08-24T00:00:00-04:00", "review_policy": "synthetic_waiver_user_authorized_2026-08-24",
        "user_review_claim": False, "generator_seed": generation["seed"],
        "files": {split: source[f"sft:{split}"] for split in ("train", "validation", "test", "challenge")},
        "annotation_files": {split: source[f"annotations:{split}"] for split in ("train", "validation", "test", "challenge")},
        "rl_files": {split: source[f"rl:{split}"] for split in ("train", "validation", "test", "challenge")},
        "audit": {"name": "audit_report.json", "sha256": hashlib.sha256(audit_path.read_bytes()).hexdigest(), "rows": audit["rows"]},
        "rates": generation["rates"],
        "training_policy": {"base_model": "Qwen/Qwen3-0.6B", "epochs": 1, "completion_only_masking": True, "seed": 3407, "max_sequence": 1024, "packing": False},
    }
    path = args.root / "manifest.json"; path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"manifest": str(path), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}, indent=2)); return 0


if __name__ == "__main__": raise SystemExit(main())
