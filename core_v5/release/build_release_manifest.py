#!/usr/bin/env python3
"""Create reproducible file manifests and SHA-256 lists for a model release."""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(4 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--model-id", required=True)
    parser.add_argument("--base-model", required=True)
    parser.add_argument("--adapter-sha256", required=True)
    args = parser.parse_args()

    excluded = {"SHA256SUMS", "release-manifest.json"}
    paths = sorted(
        path for path in args.root.rglob("*")
        if path.is_file() and path.name not in excluded
    )
    files = []
    checksum_lines = []
    for path in paths:
        relative = path.relative_to(args.root).as_posix()
        digest = sha256(path)
        size = path.stat().st_size
        files.append({"path": relative, "size_bytes": size, "sha256": digest})
        checksum_lines.append(f"{digest}  {relative}")

    formats = {}
    for directory in (
        "Adapter-LoRA", "Merged-HuggingFace-FP16", "MLX-FP16",
        "MLX-4bit-COMPACT-ARCHIVE", "MLX-8bit-RECOMMENDED",
    ):
        path = args.root / directory
        if path.is_dir():
            formats[directory] = sum(item.stat().st_size for item in path.rglob("*") if item.is_file())
    manifest = {
        "schema_version": 1,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "model_id": args.model_id,
        "base_model": args.base_model,
        "source_adapter_sha256": args.adapter_sha256,
        "formats_total_bytes": formats,
        "files": files,
    }
    (args.root / "release-manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n"
    )
    (args.root / "SHA256SUMS").write_text("\n".join(checksum_lines) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
