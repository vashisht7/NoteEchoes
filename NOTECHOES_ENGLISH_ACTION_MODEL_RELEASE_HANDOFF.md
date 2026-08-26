# NoteEchoes English Action Model Release Handoff

The current app release is the public MLX 8-bit model at `Vashisht7/noteechoes-english-voice-intent-action-qwen3-0.6b-mlx-8bit`, pinned to immutable Hugging Face revision `b829d1d480c0bc0226326e36f009ae825af60f18`.

Main weights are `633,442,531` bytes with SHA-256 `4f7acb40c1bcf6c4bf8a3b6f0350e595ef6ae8130469bcfc85cceec7eb4114ea`. The exact 11-file app runtime is `649,376,484` bytes. Source adapter SHA-256 is `83a814988549ede2fb5bdbff28914b001fc58e449681960aeda9cc09351fd1e8`.

The full frozen MLX evaluation completed 1,200/1,200 rows with 100% operational accuracy, JSON validity, Core v5 schema validity, intent routing, tool routing, confirmation handling, and challenge safety. Strict exact match was 91.4167%. The 26-case app-style critical regression also passed every operational gate.

The final merge is the dequantized NF4 QLoRA merge. Do not substitute the ordinary FP16-base merge, an earlier adapter, or the archived 4-bit model.

The iOS downloader is pinned and verifies exact file sizes and hashes. English voice captures use Core v5; Hindi, Telugu, and mixed captures retain deterministic fallback. Tool output remains a proposal and cannot execute without provider validation, permissions, and confirmation. The Live Activity title supports two lines and denser spacing for 3–4 checklist items. The voice overlay records explicit local accepted/corrected feedback.

Canonical Desktop documentation and deployables are under `/Users/vashishtdevasani/Desktop/NoteEchoes Voice Intent and Action Engine Documentation`. The current model is under `04 Deployable Models/Current-English-Voice-Intent-and-Action-Qwen3-0.6B`; detailed evidence and next-agent instructions are in `07 Current Intent and Action Model/FINAL_ENGLISH_ACTION_MODEL_RELEASE_AND_APP_HANDOFF.md`.
