#!/usr/bin/env python3
"""Create a sub-800 MB fidelity-preserving MLX 8-bit release.

Most weights use affine 8-bit quantization. The final transformer decision
layers remain FP16 because release-gate testing showed that quantizing those
layers erased small intent-routing corrections from the promoted LoRA adapter.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from mlx_lm.convert import convert


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--hf-path", required=True)
    parser.add_argument("--mlx-path", type=Path, required=True)
    parser.add_argument("--fp16-final-layers", type=int, default=8)
    parser.add_argument("--total-layers", type=int, default=28)
    args = parser.parse_args()
    first_fp16 = args.total_layers - args.fp16_final_layers

    def predicate(path, _module):
        match = re.search(r"(?:^|\.)layers\.(\d+)(?:\.|$)", path)
        if match and int(match.group(1)) >= first_fp16:
            return False
        return True

    convert(
        hf_path=args.hf_path,
        mlx_path=str(args.mlx_path),
        quantize=True,
        q_group_size=64,
        q_bits=8,
        dtype="float16",
        quant_predicate=predicate,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
