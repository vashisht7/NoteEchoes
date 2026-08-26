# Core v5 bake-off status

The repository pins `mlx-swift-lm` 2.31.3 and `mlx-swift` 0.31.6. The 2.31.3 release includes Qwen3.5/Qwen3.5-MoE text support, `qwen3_5_text`, and Qwen3.5 performance fixes. This removes the source-level architecture blocker but does not replace a physical-device run.

Current public reference artifacts:

- Qwen3.5-0.8B MLX 4-bit: approximately 652 MB repository size / 625 MB weights, slightly above the preferred 600 MB text-model target.
- Qwen3-0.6B MLX 4-bit: approximately 351 MB.

The 300-case probe is `core_v5_probe_300_draft.jsonl`. It is balanced 100/100/100 across English, Hindi, and Telugu families, but remains deliberately marked `draft_not_frozen` until every transformed v5 label is reviewed and the Hindi/Telugu cases receive native-language approval.

No base winner has been selected. The next valid measurement is the same probe on both unmodified candidates on Mac and a physical iPhone, recording schema accuracy, intent/entity/item metrics, p50/p95 latency, cold start, peak memory, energy, and installed size.

Primary references:

- https://github.com/ml-explore/mlx-swift-lm/releases/tag/2.31.3
- https://github.com/ml-explore/mlx-swift-lm/blob/main/Libraries/MLXLLM/LLMModelFactory.swift
- https://huggingface.co/Qwen/Qwen3.5-0.8B-Base
- https://huggingface.co/mlx-community/Qwen3.5-0.8B-MLX-4bit
- https://huggingface.co/mlx-community/Qwen3-0.6B-4bit
