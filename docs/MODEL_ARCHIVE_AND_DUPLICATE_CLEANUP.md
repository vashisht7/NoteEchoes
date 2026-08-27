# NoteEchoes Model Archive and Duplicate Cleanup

Completed: 2026-08-27

The canonical model archive is:

`/Users/vashishtdevasani/Desktop/NoteEchoes Voice Intent and Action Engine Documentation`

The current application uses the MLX 8-bit model in:

`04 Deployable Models/01 CURRENTLY USED - English Voice Intent and Action - Qwen3 0.6B/MLX-8bit-RECOMMENDED`

Runtime identity:

- Hugging Face: `Vashisht7/noteechoes-english-voice-intent-action-qwen3-0.6b-mlx-8bit`
- Revision: `b829d1d480c0bc0226326e36f009ae825af60f18`
- Main weights SHA-256: `4f7acb40c1bcf6c4bf8a3b6f0350e595ef6ae8130469bcfc85cceec7eb4114ea`

All unique current, previous, earlier, and rejected conversion model weights were moved into the canonical archive. Current training assets remain under `07 Current Intent and Action Model`; older Core Router training assets remain under `05 Previous Model Training and Evaluation`.

The repository retains release scripts under `core_v5/release` but no longer carries redundant generated model binaries. Approximately 16.4 GiB of byte-verified duplicate outputs was moved to the recoverable Trash batch `NoteEchoes-model-duplicates-2026-08-27.4Yv9wY`.

See the archive's `MODEL_INVENTORY.md`, `MODEL_ARCHIVE_AND_DUPLICATE_CLEANUP.md`, and `04 Deployable Models/00 START HERE - CURRENT MODEL.md` before selecting or publishing a model.
