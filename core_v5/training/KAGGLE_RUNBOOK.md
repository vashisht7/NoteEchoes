# Core v5 Kaggle runbook

No training notebook should be started from staging data. The first cell must run the release audit and `train_sft.py` independently rechecks the signed manifest before importing GPU libraries or downloading a model.

1. Confirm Kaggle GPU remaining time is at least the estimated run plus the reserved eight hours.
2. Attach one immutable private dataset version containing the four JSONL splits, audit report, manifest, schema, and checksums.
3. Select exactly one bake-off winner. Do not run both fine-tunes concurrently.
4. Select Kaggle's `GPU T4 x2`, install the pinned requirements, and launch `train_sft.py` with `torchrun --standalone --nproc_per_node=2` and the immutable manifest.
5. Preserve checkpoints every 250 steps and resume only from a checkpoint whose run manifest has identical hashes.
6. Stop if the audit fails, multilingual validation regresses, a repeated failure class appears, or quota approaches the eight-hour reserve.

After SFT passes the frozen evaluation gates, `train_grpo.py` may continue from `adapter-final`. It independently verifies the RL JSONL hashes and row counts, uses the deterministic `reward_core_v5.py`, and checkpoints every 50 steps. Do not start GRPO merely because SFT finished; start it only when the reference reward agrees with manual error analysis on sampled outputs.

The local staging manifest is intentionally incompatible with this trainer because it has `status=draft_not_frozen`, not `release_ready=true`.
