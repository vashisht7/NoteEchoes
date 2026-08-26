# NoteEchoes Core v5 — Multilingual Dictation and Action Model Implementation Plan

Last updated: 2026-08-26
Status: superseded by the completed English action release; see `NOTECHOES_ENGLISH_ACTION_MODEL_RELEASE_HANDOFF.md`.
Audience: the next model/data/application agent

## 1. Executive decision

Build a compact NoteEchoes-owned specialist model that converts imperfect speech transcripts into a cleaned transcript plus a strict, future-proof action proposal. Keep speech recognition, operating-system permissions, contact resolution, storage, notifications, and actual tool execution in the application.

The recommended base-model bake-off is:

1. `Qwen/Qwen3.5-0.8B` — preferred candidate if MLX conversion and physical-device inference pass.
2. `Qwen/Qwen3-0.6B` — stable fallback if Qwen3.5 deployment is immature or slower than the product budget.
3. Keep the existing Qwen2.5-1.5B Core v4 model as the shipping control until Core v5 wins every release gate.

Do not train a foundation model from scratch. “In-house” should mean that NoteEchoes owns the task contract, curated dataset, fine-tuning adapter/merged derivative, evaluation suite, quantized release, application integration, and release process. The underlying base model remains a third-party Apache-2.0 model and must retain its licence notices.

## 2. What has been completed so far

### First experiment

- Base: Qwen3 0.6B, 4-bit.
- Attractive size: approximately 351 MB.
- Displayed training loss: approximately 0.0031.
- Problem: no configured evaluation set in that run; English appeared useful, but Telugu/Hindi product behaviour was weak.
- Lesson: low training loss is not evidence of product correctness.

### Intermediate Qwen2.5 v3 work

- Increased capacity to the 1.5B family.
- Recorded comparison passed approximately 915/1,550 checks, or 59%.
- Weaknesses included combined actions, multilingual routing, negative commands, clarification and stable output mapping.

### Current production model: Core v4

- Base: Qwen2.5-1.5B-Instruct.
- Delivery: MLX 4-bit, approximately 839 MiB.
- Final training set: 6,677 rows; validation 534; test 543; challenge 168.
- Best checkpoint: checkpoint 200.
- Successful trainer runtime: approximately 65.8 minutes.
- Raw final-model score: 969/1,292, or 75.0%.
- Model plus Dart guardrails score: 1,292/1,292 on the frozen suite.

Core v4 is the best current shipping fallback. It should not be described as universally perfect: the suite is mainly synthetic, only 289 training rows contain explicit checklist items, and email/message/prompt examples were deliberately excluded.

## 3. Product capability contract for Core v5

### The model must do

- Clean raw ASR text: punctuation, capitalization, fillers, false starts and self-corrections.
- Preserve meaning, names, dates, quantities, places and user wording.
- Understand English, Telugu, Hindi, Romanized Telugu, Romanized Hindi and realistic code-switching.
- Recognize `cancel`, `finish`, `delete last segment`, and natural correction language.
- Distinguish capture from a question about saved memories.
- Classify and structure:
  - note/thought;
  - checklist;
  - single task;
  - reminder proposal;
  - calendar-event proposal;
  - message draft;
  - email draft;
  - short prompt draft;
  - idea, decision and project update;
  - saved-memory query;
  - no-op/cancel/clarification.
- Extract only grounded checklist items, recipients, dates, times, people and places.
- Produce concise titles rather than copying the full dictation.
- Propose an extensible tool name and arguments without claiming that the tool ran.
- Request clarification when a recipient, destination, time or destructive/irreversible action is ambiguous.

### Minimum language promise

- English: every supported action, including message, email and short/long prompt drafting.
- Hindi and Telugu, including common Romanized/code-mixed speech: notes, checklists, tasks, reminders, calendar proposals, short messages, short emails, ideas, decisions, project updates, cancel/correct and memory queries.
- Hindi/Telugu prompts: short prompt generation is required; long sophisticated prompt generation is an optional stretch gate and must not block the core release.

### The model must never do

- Send an email or message.
- Choose a contact silently when multiple contacts match.
- Schedule a reminder/calendar event without application confirmation.
- Claim that an external action succeeded.
- Invent checklist items, recipients, dates, attachments or facts.
- Persist user data.
- Bypass permissions, safety policy or user confirmation.

## 4. First-principles runtime architecture

```text
Microphone
  -> audio front end / VAD
  -> ASR provider
  -> raw transcript segments
  -> Core v5 NORMALIZE mode
  -> Core v5 ACTION mode
  -> strict schema validator
  -> application action registry
  -> user confirmation when required
  -> OS/service execution
  -> persist actual result
```

Use the same loaded model weights for NORMALIZE and ACTION modes. Start with two calls because they are easier to evaluate independently. Merge into one response only after measurements prove that latency improves without reducing correction or action accuracy.

UI Cancel remains deterministic application logic: it must stop recording, cancel transcription, delete temporary audio and return no note. Spoken cancellation should be recognized by the model/command layer, but persistence must still enforce the cancellation result.

## 5. Future-proof action envelope

Core v5 should return one JSON object and no prose:

```json
{
  "schema_version": 5,
  "language": "en|hi|te|hi-roman|te-roman|mixed|unknown",
  "mode": "capture|query|control",
  "normalized_text": "...",
  "intent": "note|checklist|task|reminder|calendar|message|email|prompt|idea|decision|project_update|memory_query|cancel|clarify|noop",
  "title": "...",
  "items": [{"text": "..."}],
  "entities": {
    "recipient_query": null,
    "date_phrase": null,
    "time_phrase": null,
    "people": [],
    "place": null,
    "subject": null
  },
  "draft": null,
  "proposed_tool": {
    "name": null,
    "arguments": {}
  },
  "confidence": 0.0,
  "requires_confirmation": false,
  "clarification_question": null
}
```

Use grammar-constrained decoding where the iOS runtime permits it. Independently validate schema, enums, lengths and grounding in Dart. Reject or repair invalid output before it reaches storage or an executor.

## 6. MCP-style application integration

Build an application-level `ActionProviderRegistry`. The model proposes capabilities; registered providers execute them.

Example provider names:

- `notes.create`
- `checklists.create`
- `reminders.propose`
- `calendar.propose_event`
- `messages.compose`
- `email.compose`
- `prompts.save`
- `memory.search`

Each provider declares a versioned argument schema, required permissions, confirmation policy and result schema. The application maps providers to iOS/macOS APIs, share sheets, URL schemes, backend services or future MCP-compatible servers.

For messages and email, the safe flow is `understand -> resolve contact -> show draft -> user presses Send -> execute -> record actual result`. The model never receives authority merely because it emitted a tool name.

## 7. Base-model bake-off

### Candidate A — Qwen3.5-0.8B, recommended conditional winner

Reasons to test:

- 0.8B class remains compatible with the overall storage target after 4-bit quantization.
- Official Qwen material reports support for 201 languages/dialects, including Hindi and Telugu.
- It is explicitly designed for agent/tool behaviour.
- Apache-2.0 is straightforward for a commercial derivative when notices are retained.
- It has substantially more current multilingual and agent training than the original Qwen3 0.6B.

Risks:

- Newer hybrid DeltaNet/attention architecture.
- MLX/llama.cpp/mobile runtime support must be proved, not assumed.
- Large vocabulary can increase quantized size and memory beyond a naïve 0.8B estimate.
- Do not include or load the vision encoder for this text-only product path.

### Candidate B — Qwen3-0.6B, deployment-safe fallback

Reasons to keep:

- Apache-2.0.
- Official model card reports 100+ languages; base training reports 119 languages.
- 32K context and existing small quantized builds.
- Familiar Qwen architecture and easier MLX deployment.
- Approximately 351–462 MB depending on quantization/container.

Risk: less capacity for multilingual cleanup plus strict multi-action extraction, so it needs stronger data and may lose to 0.8B.

### Candidate C — Gemma 3 1B

Do not select without a direct Telugu bake-off. Although some general Gemma material describes broad multilingual training, the official Gemma 3 release table labels the 1B variant as English-only; the 4B multilingual variant is too large for this product budget. Licence acceptance/distribution requirements also add friction.

### Candidate D — Llama 3.2 1B

Reject for this release: its officially supported languages include Hindi but not Telugu, and its licence/distribution conditions are less convenient than Apache-2.0 for this use.

### S1-mini

Use as a design/evaluation reference, not as the final base. It is a 0.6B English-only text normalizer, not ASR and not a NoteEchoes action model. Adding its approximately 462 MiB Q4 file alongside Core v4 would exceed the preferred storage budget.

### Bake-off procedure before training

1. Convert/load unmodified Qwen3.5-0.8B and Qwen3-0.6B in the intended Apple runtime.
2. Run 300 frozen zero-shot/few-shot cases: 100 English, 100 Hindi/code-mixed, 100 Telugu/code-mixed.
3. Measure valid JSON, intent, grounded items/entities, latency, peak memory and final Q4 size.
4. Reject any candidate that cannot run reliably on the physical target device or cannot fit the product budget.
5. Fine-tune only the winner. If results are statistically close, choose Qwen3-0.6B for lower deployment risk.

## 8. Production dataset specification

Target initial corpus: 36,000 examples.

| Split | Rows | Review requirement |
| --- | ---: | --- |
| Train | 30,000 | sampled human review plus automatic validation |
| Validation | 2,400 | 100% human reviewed |
| Test | 2,400 | 100% human reviewed and frozen |
| Challenge | 1,200 | 100% human reviewed, adversarial and frozen |

### Training-language allocation

- English: 12,000 rows (40%).
- Hindi native/mixed/Romanized: 9,000 rows (30%).
- Telugu native/mixed/Romanized: 9,000 rows (30%).

Within Hindi and Telugu, allocate approximately 45% native script, 30% Romanized, and 25% code-mixed. Preserve regional/common colloquial wording rather than translating English templates literally.

### Training intent allocation

| Intent family | Share | Train rows |
| --- | ---: | ---: |
| Notes/thoughts/ideas/decisions/project updates | 12% | 3,600 |
| Multi-item checklists | 15% | 4,500 |
| Single tasks | 10% | 3,000 |
| Reminders | 12% | 3,600 |
| Calendar proposals | 8% | 2,400 |
| Message drafts | 10% | 3,000 |
| Email drafts | 10% | 3,000 |
| Prompt drafts | 6% | 1,800 |
| Memory queries | 7% | 2,100 |
| Cancel/correct/no-op/negative/clarification | 10% | 3,000 |

These totals refer to the 30,000-row training split. Validation/test/challenge should preserve broad coverage but deliberately over-sample rare and high-risk failures.

### Required variation dimensions

Every intent must cover combinations of:

- concise commands and long natural mind dumps;
- filler words, pauses, repetitions and false starts;
- `actually`, `no`, `I mean`, replace/delete/cancel corrections;
- missing punctuation and ASR-like word errors;
- one action versus multiple actions in the same utterance;
- positive action, explicit negative action and discussion-about-an-action;
- ambiguous and complete date/time phrases;
- multiple possible recipients and unknown recipients;
- native names, English names, acronyms, phone-like numbers and email addresses;
- polite requests, indirect speech and imperative speech;
- native script, Romanization and within-sentence code-switching;
- queries that must not be saved as notes;
- adversarial instructions embedded in dictated content.

At least 30% of examples should resemble raw ASR output. At least 20% should contain realistic code-switching. At least 15% should contain multiple candidate actions or a correction. These dimensions overlap; do not simply add the percentages.

### Data-source hierarchy

1. Consented real NoteEchoes recordings plus manually corrected transcripts.
2. Native-speaker-authored utterances and corrections.
3. Existing v2/Core v4 examples that pass renewed review.
4. Larger-model synthetic generation used only for breadth.
5. Programmatic perturbations used only after a clean gold example exists.

Never call AI-generated examples “human reviewed” unless a reviewer actually checked the source utterance, normalized text and complete expected JSON.

### Annotation record

Each example must store:

- immutable example ID and semantic-family ID;
- source type and consent/provenance;
- language/script/code-mix labels;
- raw transcript and gold normalized transcript;
- expected Core v5 JSON;
- grounded character/token spans for items and entities;
- ambiguity and confirmation labels;
- ASR corruption tags;
- reviewer, review status and correction history;
- safety/adversarial tags.

### Split and leakage rules

- Freeze test and challenge before training.
- Split by semantic family, speaker and scenario, never random paraphrase row.
- Keep all variants of one seed in one split.
- Normalize and exact-deduplicate first.
- Run near-duplicate detection across all splits.
- Keep real recordings from one speaker/session in one split.
- Never tune prompts, guardrails or model hyperparameters against the final test/challenge labels.

## 9. Dataset production workflow

1. Lock Core v5 schema and executor semantics.
2. Write 1,000 human-quality gold seeds covering every intent/language cell.
3. Have Hindi and Telugu native reviewers correct language, naturalness and labels.
4. Generate controlled paraphrases and ASR-corrupted variants from reviewed seeds.
5. Generate targeted rare/adversarial cases separately.
6. Validate JSON schema and grounding automatically.
7. Deduplicate and assign semantic-family IDs.
8. Create frozen validation/test/challenge splits.
9. Perform 100% human review of all non-training splits.
10. Produce a signed manifest with row counts, hashes, provenance and review statistics.

Dataset creation is expected to take more calendar time than GPU training. A credible first production corpus requires roughly 60–120 human-review hours depending on reviewer speed and how much real speech is collected. Synthetic generation can be fast; trustworthy labels are the bottleneck.

## 10. Training plan

### Stage 0 — compatibility bake-off

- Quantize/load both candidate bases.
- Run the 300-case frozen probe on Mac and physical iPhone.
- Budget: 0.5–1.5 Kaggle GPU hours if Kaggle is needed; most device testing uses no Kaggle GPU.

### Stage 1 — supervised fine-tuning

- Method: QLoRA/LoRA with completion-only masking.
- Start with rank 32, alpha 64, dropout 0.05 and rsLoRA.
- Maximum sequence: 1,024 initially; increase only if real long-dictation truncation is measured.
- Packing off for the first audited run.
- Deterministic seed and data seed.
- One epoch initially, evaluation/checkpoint every fixed fraction of an epoch.
- Train NORMALIZE and ACTION examples in one curriculum with explicit mode tokens.
- Oversample correction/cancel and low-resource language failures, not easy templated rows.
- Budget for one 30,000-row 0.6–0.8B run: approximately 1–2.5 Kaggle GPU hours depending on assigned GPU, sequence lengths and dataloader speed.

### Stage 2 — failure-directed second run

- Evaluate the raw merged model first.
- Add only new examples representing measured failures.
- Do not regenerate the entire corpus or blindly add epochs.
- Budget: approximately 1–2 Kaggle GPU hours.

### Stage 3 — merge, quantize and evaluate

- Save adapter, merged Hugging Face model, tokenizer/template and training manifest.
- Convert to MLX 4-bit; optionally produce GGUF Q4_K_M for desktop diagnostics.
- Evaluate both merged and final quantized artifacts.
- Budget: approximately 1–2 GPU hours; conversion may be CPU-bound.

### Total expected Kaggle budget

- Lean successful path: approximately 4–6 GPU hours.
- Conservative path including one failed/aborted experiment: approximately 7–9 GPU hours.
- Do not exceed 10 GPU hours without stopping for a written failure review.

## 11. Current Kaggle quota

Verified from the signed-in Kaggle Settings page on 2026-08-24:

- GPU quota: 12 hours 10 minutes used out of 30 hours.
- GPU time remaining: 17 hours 50 minutes.
- TPU quota: 0 hours used out of 20 hours.

The planned 4–9 GPU-hour program fits the currently displayed GPU balance, but Kaggle quota reset timing, accelerator availability and notebook overhead can change. Recheck immediately before starting. Do not create duplicate concurrent runs.

## 12. Training and project timeline estimate

GPU execution is not the main schedule risk.

| Work | Expected elapsed effort |
| --- | --- |
| Schema freeze and bake-off suite | 1–2 days |
| Candidate conversion/device compatibility | 0.5–1 day |
| Gold dataset design and authoring | 3–7 days |
| Native-language review | 3–10 days, parallelizable |
| Dataset generation/audit/splitting | 1–3 days |
| First Kaggle training run | 1–2.5 GPU hours |
| Evaluation and error analysis | 1–2 days |
| Corrective run plus quantization | 2–4 GPU hours |
| Dart/iOS integration and physical-device gates | 2–5 days |

Realistic production calendar estimate: approximately 2–4 weeks with available Hindi and Telugu reviewers. A rushed synthetic-only model could be trained in a day, but it would repeat the evidence weakness of earlier models.

## 13. Release gates

Report every metric separately for English, Hindi, Romanized Hindi, Telugu, Romanized Telugu and code-mixed subsets.

| Gate | Required result |
| --- | ---: |
| Valid JSON/schema | 100% |
| English intent accuracy | >= 98% |
| Hindi/Telugu intent accuracy | >= 95% each |
| Checklist item precision | >= 99% |
| Checklist item recall | >= 97% |
| Item order accuracy | >= 99% |
| Hallucinated recipients/items/dates | 0 on challenge |
| Cancel/negative-command safety | 100% on challenge |
| Reminder/calendar confirmation safety | 100% |
| Message/email recipient clarification | 100% when ambiguous |
| Tool name and argument schema | >= 99% |
| Raw-model overall exact contract | >= 95% |
| Final Q4 degradation versus merged model | <= 1 percentage point |
| Physical-device end-to-end locked suite | 100% |

Also measure title quality, correction resolution, ASR-noise robustness, p50/p95 latency, peak memory, cold-start time, energy use and downloaded size. The model cannot replace Core v4 merely by having lower validation loss.

## 14. Size target

Target text-model download: 450–600 MB maximum. Combined target:

- App: approximately 107 MB.
- Current Whisper Base fallback: approximately 154 MB.
- Core v5 Q4: target 450–600 MB.
- Total: approximately 711–861 MB before filesystem overhead.

Hard rejection conditions:

- complete installed footprint above 1.2 GB;
- sustained device memory pressure or thermal instability;
- runtime architecture unavailable in the production iOS inference layer;
- slower end-to-end save latency than Core v4 without a meaningful accuracy gain.

## 15. Safety and product rules

- A model output is a proposal, never proof of execution.
- All external sends require a visible draft and explicit user action by default.
- Resolve recipients against authorized local/application data after inference.
- Do not place API keys in Dart or model prompts.
- Record the exact provider/tool result before marking anything sent or scheduled.
- Keep user notes and recordings out of training unless explicit informed consent exists.
- Provide deletion/export controls for consented training samples.
- Preserve an offline path and disclose when cloud ASR is used.

## 16. Deliverables the next agent must produce

1. `core_v5.schema.json` and human-readable contract.
2. Model bake-off notebook and 300-case frozen results.
3. Dataset-generation specification and scripts.
4. Provenance/review manifest and split-leakage audit.
5. Train/validation/test/challenge JSONL files.
6. Reproducible Kaggle notebook with resume/checkpoint support.
7. Adapter, merged model, MLX Q4 and optional GGUF artifacts.
8. Raw merged and quantized evaluation reports by language and intent.
9. Dart Core v5 adapter, validator and action-provider registry.
10. Physical iPhone end-to-end results for checklist, reminder, message, email, cancel and correction.
11. Updated Hugging Face model card, licence notices, checksums and immutable revision.
12. Updated model book and application handoff.

## 17. Stop conditions

Stop and diagnose instead of spending more GPU time when:

- the candidate cannot run through the intended Apple runtime;
- data leakage or schema inconsistency is detected;
- Telugu/Hindi validation deteriorates while aggregate loss improves;
- the raw model relies on phrase-specific Dart repairs to pass;
- a second run repeats the same failure class;
- quantization breaks structured output;
- remaining Kaggle quota would fall below the reserved 8-hour safety margin.

## 18. Immediate next actions

1. Do not start training yet.
2. Freeze the Core v5 schema and action-provider semantics.
3. Build and review the 300-case candidate bake-off suite.
4. Verify Qwen3.5-0.8B text-only MLX conversion and physical-device performance.
5. Compare Qwen3.5-0.8B with Qwen3-0.6B.
6. Select the base using measured multilingual contract accuracy, size and latency.
7. Produce and audit the 36,000-example dataset according to this document.
8. Start one checkpointed Kaggle run only after the frozen splits and manifests exist.

The guiding principle is: train the model to understand variable human language and propose structured actions; keep state, permissions, confirmations and real-world effects deterministic in the application.
