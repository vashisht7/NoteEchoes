# NoteEchoes Core v5 implementation status

Updated: 2026-08-24

## Completed safely

- Frozen machine-readable action envelope and annotation schemas.
- Human-readable provider/confirmation contract.
- Strict Dart parser/validator with exact-key, enum, bounds, grounding, intent/tool, and confirmation checks.
- Versioned application `ActionProviderRegistry` that refuses unknown providers, missing permissions, invalid arguments, and unconfirmed writes/sends.
- Core v5 prompt path added without replacing the shipping Core v4 route.
- Legacy Core v4 and multilingual v2 staging importer with provenance and immutable IDs.
- Exact deduplication, semantic-family/exact/near-duplicate split audit, grounding-span checks, review gates, hashes, and fail-closed release counts.
- Attributable review-decision workflow with correction-history hashes.
- Draft 300-case probe balanced across English, Hindi, and Telugu.
- Checkpointed, hash-gated Kaggle training entry point and notebook.
- Focused Flutter tests pass for the validator, provider permissions/confirmation, and v5 prompt.

## Evidence discovered

- Kaggle account: `vashishtdevasani`.
- Kaggle GPU quota at the successful launch: approximately 12:22 used of 30 hours.
- Private Kaggle dataset: `vashishtdevasani/noteechoes-core-v5-synthetic-rl-sft-frozen-v1`.
- Active notebook: `vashishtdevasani/noteechoes-core-v5-synthetic-sft-run-1`.
- Qwen3-0.6B completion-only QLoRA is running across two T4 GPUs; the first distributed optimizer steps completed successfully. Initial ETA was approximately 6 hours 17 minutes for the full 60,000-record epoch.
- A separate hash-gated `train_grpo.py` can continue from the SFT adapter using four sampled completions per prompt and the deterministic Core v5 schema, grounding, tool, confirmation, and no-execution-claim reward.
- Voice capture now reviews the cleaned note before dismissal with `Looks right`, `Fix`, and `Skip feedback` controls. Accepted/corrected pairs are stored append-only on device with `upload_consent=false`; no note or transcript is uploaded automatically.
- Exact standalone cancellation commands discard the recording without creating a note. Mentions of cancellation inside a real note do not trigger this control path.
- A thread heartbeat checks the active Kaggle run every 15 minutes and reports progress, errors, quota, checkpoints, and validation.
- Legacy import: 10,240 unique staging rows after removing 6,334 exact duplicates.
- Every imported row is correctly marked unreviewed.
- Only 10 automatically convertible checklist rows remain under the strict v5 contract.
- 559 multi-action legacy rows require re-annotation rather than unsafe automatic conversion.
- The strengthened audit found 10 near-duplicate clusters crossing legacy splits; staging therefore fails the leakage gate.
- The pinned `mlx-swift-lm` 2.31.3 includes Qwen3.5 text support, but the physical iPhone is currently offline.
- Public MLX artifacts are approximately 652 MB for Qwen3.5-0.8B 4-bit and 351 MB for Qwen3-0.6B 4-bit. The former is above the preferred 600 MB target and must earn its size in the measured bake-off.

## Experimental synthetic run authorized

On 2026-08-24 the user explicitly waived native Hindi/Telugu review for the current experimental run and requested fresh data plus training. `ready_synthetic_v1` now contains 36,000 automatically audited annotations, paired NORMALIZE/ACTION SFT records, deterministic RL reward inputs, and an immutable manifest. The manifest does not claim human review.

The first run uses Qwen3-0.6B because its public 4-bit MLX artifact is comfortably within the preferred on-device size target. The Kaggle runner pins each quantized worker to its local T4 and uses distributed data parallelism; this avoids unsupported P100 kernels and unsafe automatic 4-bit device placement.

## Remaining production stop conditions

The experimental run may proceed, but production replacement of Core v4 still requires:

1. The 300-case probe has not received full human/native-language review.
2. Validation, test, and challenge are synthetic and not named-human approved.
3. Legacy rows remain quarantined; only the fresh leakage-safe synthetic corpus is authorized for this experiment.
4. A physical iPhone must be online for candidate size/latency/memory testing.
5. The trained artifact cannot replace Core v4 until it passes the frozen product and physical-device gates.

The current training job is an explicitly authorized experiment. Treating its synthetic results as human-reviewed production evidence would still be incorrect.
