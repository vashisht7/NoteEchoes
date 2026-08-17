# NoteEchoes v2.8.0

## Semantic Topics and Related Notes

- Adds the optional Multilingual E5 Small 8-bit model for private semantic understanding across 94 languages.
- Finds related notes by meaning, not only matching words.
- Groups strong relationships into suggested Topics sections.
- Uses local Qwen, when installed, to create grounded topic names and summaries.
- Lets users confirm, dismiss, and rename topic suggestions.
- Adds Related Notes inside the note editor with confidence and review controls.
- Keeps vectors, relationships, clusters, confidence, and user decisions in the local SQLite database.

## Model safety and delivery

- The 123 MB semantic model is downloaded only after user confirmation.
- Downloads resume after interruption and are verified against pinned file sizes and SHA-256 hashes before use.
- Partial or damaged downloads are reported as needing repair.
- Notes, embeddings, and topic information remain on the device.

## Storage estimate

- Installed app: approximately 104 MB before App Store compression.
- Semantic model and tokenizer: 123 MB.
- Qwen: approximately 351 MB.
- Whisper: approximately 147 MB.
- Expected total with every optional model: approximately 725–800 MB, including indexes and normal cache variation.

## Verification

- Full Flutter test suite passes, including durable semantic relationship and topic-decision storage.
- Targeted static analysis is clean.
- Signed generic iOS Release build and deep code-signature verification pass.
- The quantized ONNX model was executed successfully on Apple Silicon with 384-dimensional normalized embeddings, including English and Telugu semantic smoke cases.
