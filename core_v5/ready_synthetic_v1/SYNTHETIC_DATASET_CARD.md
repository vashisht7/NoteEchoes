# NoteEchoes Core v5 synthetic experimental dataset v1

This corpus was generated deterministically on 2026-08-24 after the user explicitly waived native Hindi/Telugu review for the experimental training run. It must not be described as human-reviewed or production-proven.

## Composition

- 36,000 annotated action examples.
- 12,000 semantic families, exactly three speech variants per family.
- Train 30,000; validation 2,400; test 2,400; challenge 1,200.
- English 40%; Hindi family 30%; Telugu family 30%.
- 50% contain ASR/correction noise tags.
- 21.8% are labeled code-mixed.
- 16.7% contain explicit self-correction.
- Paired NORMALIZE and ACTION messages produce 60,000 SFT training records.
- One RL prompt/reference record per annotation supports deterministic GRPO rewards.

## Guarantees

- Exact schema, bounds, tool/intent mapping, grounding spans, counts, hashes, and split isolation pass the automated audit.
- All variants of a semantic family remain in one split.
- No user notes, recordings, contacts, credentials, or other private data are included.
- The manifest records `user_review_claim=false` and the synthetic review waiver.

## Limitations

- The language is compositional and template-derived.
- No native-language naturalness review was performed.
- It does not substitute for real microphone/ASR recordings.
- Test scores on this corpus measure contract learning and controlled robustness, not universal real-world quality.
- A future production release should add consented real speech and native-speaker review without tuning against this frozen test/challenge set.
