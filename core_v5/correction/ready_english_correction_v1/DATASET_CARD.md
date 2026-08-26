# English Action Failure Correction Dataset

This frozen continuation dataset repairs observed NoteEchoes action failures without restarting base training.

## Composition

- Train: 6,000 rows
- Validation: 600 rows
- Test: 600 rows
- Challenge: 600 rows
- Total: 7,800 unique rows and 7,800 unique prompt/completion fingerprints
- Language: English ACTION rows only; English NORMALIZE replay
- Correction focus: message, prompt, checklist, task, reminder, and memory query
- Replay: frozen original ACTION and NORMALIZE examples across all intents

The train split contains 4,200 newly generated failure-correction ACTION rows, 1,200 original English ACTION replay rows, and 600 original English NORMALIZE replay rows. Validation, test, and challenge each contain 420 correction ACTION rows, 120 original ACTION replay rows, and 60 NORMALIZE replay rows.

## Safety and quality gates

- Every ACTION completion validates against the Core v5 JSON Schema.
- No row IDs or complete prompt/completion fingerprints overlap across splits.
- Every file has a frozen SHA-256 hash and row count in `manifest.json`.
- The manifest requires continuation from adapter SHA-256 `47e8e982e2a81b7ea7904d6879bda3f5b581f2121d25b7e8c83f5feae479a8ca`.
- The training policy forbids restart from zero.

This is still a deterministic synthetic correction dataset. Passing it does not replace human-authored English ASR acceptance testing.
