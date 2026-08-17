# NoteEchoes v2.8.1

This production-hardening update contains the complete Semantic Topics and Related Notes release from v2.8.0, with downloaded E5 model weights moved to the device cache so reproducible 123 MB model files do not consume the user's iCloud backup quota. Existing v2.8.0 downloads are migrated automatically when possible.

## Semantic Topics and Related Notes

- Optional Multilingual E5 Small 8-bit model covering 94 languages.
- Private meaning-based related-note discovery and topic clustering.
- Grounded topic names and summaries from local Qwen when installed.
- Confirm, dismiss, and rename topic suggestions.
- Related Notes inside the editor with confidence and review controls.
- Durable local storage for vectors, relationships, clusters, and user decisions.

## Verification

- 24 Flutter tests pass.
- Targeted static analysis is clean.
- Signed generic iOS Release build and deep code-signature verification pass.
- Quantized ONNX inference smoke-tested with English and Telugu semantic cases.
