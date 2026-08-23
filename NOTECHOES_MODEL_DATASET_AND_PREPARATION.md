# NoteEchoes Core v4 — Model, Dataset, Training, Evaluation, and Distribution Record

Last verified: 2026-08-23

## 1. Purpose of this document

This is the authoritative technical record for the current NoteEchoes Core v4 release. It explains why the model was built, how the dataset evolved, what was trained on Kaggle, what the model can and cannot do, how the final iOS model is distributed, and what the evaluation numbers actually mean.

This document treats the older setup guides, prompt examples, multilingual v2 archive, and language-review workbook as historical reference material. They are not instructions and do not override the current Core v4 product contract.

## 2. Product problem

NoteEchoes is intended to let a user speak naturally and turn that speech into useful, remembered objects:

- Plain notes and thoughts
- Ideas, decisions, and project updates
- Tasks and spoken checklists
- Reminders requiring confirmation
- Calendar-event proposals requiring confirmation
- Questions grounded in saved notes
- Mixed utterances containing more than one action

The product must preserve the user's English, Telugu, Hindi, or Romanized/mixed-language style. It must not invent checklist steps, silently schedule an event, claim an action succeeded before iOS confirms it, or answer a memory question without retrieving the user's actual notes.

The model therefore is not a general chatbot. It is an application-specific interpreter that converts speech into a small JSON contract. The Dart application remains responsible for validation, date resolution, retrieval, confirmation, storage, and UI presentation.

## 3. Why the earlier approaches were replaced

### Original Qwen3 0.6B Unsloth run

The first visible Unsloth training used `mlx-community/Qwen3-0.6B-4bit`. It was small—approximately 351 MB—and the final training loss shown in Unsloth was approximately `0.0031`.

That result was not enough to establish product quality:

- Evaluation loss was not configured.
- Validation, test, and challenge behavior was not measured in the training UI.
- English behavior was observed to be useful, but Telugu and Hindi were weak.
- A very low training loss can mean memorization of a structured dataset; it does not prove correct routing or safe actions.

### Qwen2.5 v3 attempts

Later Qwen2.5 1.5B experiments improved model capacity, but the earlier v3 production comparison passed about `915/1,550` checks (`59.0%`) across its then-current suites. The main failures involved multilingual routing, combined actions, negative commands, clarification, and stable mapping into the application contract.

### Core v4 decision

Core v4 kept the 1.5B model size but changed the problem:

1. Narrow the neural model to a compact, explicit action schema.
2. Remove unreliable draft and agent-prompt behavior from the core multilingual model.
3. Train on a focused contract rather than a large, flexible assistant response.
4. Add deterministic application guardrails for high-cost failure types.
5. Evaluate the exact 4-bit MLX artifact used by the app.

This model-plus-deterministic-boundary design is the main reason the current product stack is more dependable. The gain did not come from a larger parameter count.

## 4. Dataset history

### 4.1 Multilingual v2 source/review pack

The historical `Note Echoes Multilingual v2.zip` contains a broad natural-speech dataset, review queue, training scripts, Unsloth configuration, validation/test/challenge splits, prompt examples, and checksums.

The separate language-review workbook contains `12,360` review rows:

| Language style | Rows |
| --- | ---: |
| Telugu native | 2,060 |
| Telugu–English mixed script | 2,460 |
| Romanized Telugu–English | 1,660 |
| Hindi native | 2,060 |
| Hindi–English mixed script | 2,460 |
| Romanized Hindi–English | 1,660 |
| Total | 12,360 |

All rows were marked approved, zero rows were excluded, and zero rows contained user corrections. The reviewer column in sampled rows says `ai_preapproved` and explicitly asks for dialect spot-checking.

This is useful breadth, but it is not the same as 12,360 independently human-validated utterances. The wording is heavily generated/templated and should be treated as synthetic training material until native speakers review representative samples.

The v2 pack also included email drafts, message drafts, and coding-agent prompts in Telugu/Hindi. Those examples describe an earlier, broader ambition. They were intentionally excluded from Core v4 because repeated training runs showed that the compact model was more reliable when focused on core capture and action behavior.

### 4.2 Final Core v4 dataset

The final Core v4 dataset is stored in:

`/Users/vashishtdevasani/Downloads/NoteEchoes-model-pipeline-v4-core/ready`

| Split | Rows | Capture | Query |
| --- | ---: | ---: | ---: |
| Train | 6,677 | 6,607 | 70 |
| Validation | 534 | 499 | 35 |
| Test | 543 | 508 | 35 |
| Challenge | 168 | 168 | 0 |
| Total | 7,922 | 7,782 | 140 |

The audit report records zero overlap between every pair of train, validation, test, and challenge splits.

#### Training language balance

| Language | Rows | Approximate share |
| --- | ---: | ---: |
| English | 1,260 | 18.9% |
| Hindi native/mixed | 1,953 | 29.3% |
| Romanized Hindi | 716 | 10.7% |
| Telugu native/mixed | 2,021 | 30.3% |
| Romanized Telugu | 727 | 10.9% |

The training split contains:

- `2,183` reminder actions
- `1,656` task actions
- `1,009` calendar-event actions
- `289` rows with explicit checklist items
- `593` ideas
- `370` decisions
- `596` project updates
- `3,392` general notes
- `70` saved-memory queries

During Core v4 conversion, the report records `784` agent-prompt examples and `1,533` draft examples skipped from training. This is the concrete evidence that Core v4 deliberately removed those behaviors rather than merely failing to learn them.

### 4.3 Dataset strengths

- Explicit train/validation/test/challenge separation with zero reported overlap
- Native Telugu and Hindi plus Romanized and code-mixed phrasing
- Structured expected outputs rather than subjective prose grading
- Negative commands such as “do not create a reminder”
- Ambiguous-time cases that should request clarification
- Combined task-plus-reminder utterances
- Notes, ideas, decisions, project updates, actions, and memory queries
- Fixed JSON schema suitable for automated evaluation

### 4.4 Dataset limitations

- The source material is heavily synthetic or template-derived.
- The language-review workbook has zero recorded human corrections.
- The dataset contains text, not real audio. It does not measure microphone quality, Whisper errors, accents, background noise, hesitations, or punctuation loss.
- English is less represented than Telugu/Hindi in the final training split.
- Only 70 training rows are memory queries.
- Only 289 training rows contain actual spoken checklist items.
- The challenge split has no queries and no explicit checklist-item rows.
- Journal and meeting labels exist in the schema, but they do not appear in the final dataset report as trained kinds.
- Email, message, and agent-prompt generation are excluded for every language in the current Core v4 system prompt, including English.

The last point is a current product-contract mismatch: prior requirements said English should support every action, but the implemented Core v4 spoken-action path stores email/message/prompt requests as ordinary notes. English draft/prompt support must be implemented through a separate routed capability or a future contract if it is still required.

## 5. Core v4 output contract

The model returns one JSON object with exactly these ordered keys:

```text
v, language, mode, kind, title, summary, actions, query_terms, ask
```

Important enums:

- `language`: `en`, `te`, `hi`, `te-roman`, `hi-roman`, `unknown`
- `mode`: `capture`, `query`
- `kind`: `note`, `idea`, `decision`, `project_update`, `journal`, `meeting`, `task_list`, `none`
- action kinds: `task`, `reminder`, `calendar_event`

Every action contains:

```text
kind, text, items, date, time, people, place
```

The contract intentionally preserves relative date phrases rather than calculating them. The application converts phrases such as “tomorrow at 6 PM” into a real date, shows confirmation, and only then calls iOS Calendar/Reminders.

## 6. Final training configuration

### Model and method

| Setting | Value |
| --- | --- |
| Base family | Qwen2.5-1.5B-Instruct |
| Training loader | `unsloth/Qwen2.5-1.5B-Instruct-bnb-4bit` or supplied warm-start model |
| Method | LoRA/QLoRA-style 4-bit training with Unsloth |
| Warm start | Yes; Version 10 used the prior Qwen2.5-derived model path |
| Epochs | 1.0 |
| Maximum sequence | 1,024 tokens |
| Packing | Off |
| Completion-only masking | On |
| Seed/data seed | 3407 |

### LoRA

| Setting | Value |
| --- | ---: |
| Rank | 32 |
| Alpha | 64 |
| Dropout | 0.05 |
| rsLoRA | On |
| Bias | None |
| Gradient checkpointing | Unsloth |
| Target modules | q/k/v/o projections plus gate/up/down projections |

### Optimization

| Setting | Value |
| --- | ---: |
| Per-device train batch | 1 |
| Per-device evaluation batch | 1 |
| Gradient accumulation | 16 |
| Effective train batch | 16 |
| Warm-start learning rate | `2e-5` |
| Fresh-start learning rate | `4e-5` |
| Warmup ratio | 0.05 |
| Weight decay | 0.01 |
| Optimizer | AdamW 8-bit |
| Scheduler | Cosine |
| Evaluation interval | 100 steps |
| Checkpoint interval | 100 steps |
| Retained checkpoints | 3 |
| Best-model metric | Evaluation loss, lower is better |
| Early stopping | Patience 4, threshold 0.0005 |

The one-epoch run corresponded to approximately `418` optimization steps. Checkpoint 100 completed, the interrupted process resumed near step 103, and the final selected best checkpoint was checkpoint 200.

### Training result

- Training runtime: `3,949.8` seconds, approximately 65.8 minutes of successful training runtime
- Training loss: `0.00464735174792235`
- Best evaluation loss: `0.02372388355433941`
- Best checkpoint: `checkpoint-200`

The total Kaggle GPU time consumed by all experiments was higher because previous attempts failed, restarted, or evaluated rejected candidates. The 65.8-minute number is the successful final trainer runtime, not the total project GPU usage.

## 7. Artifact preparation

The successful pipeline produced:

1. A LoRA adapter and checkpoints in Kaggle output
2. A merged 16-bit Hugging Face model for conversion
3. A native Apple MLX 4-bit model
4. Validation, test, release, and challenge reports
5. A deterministic Core v4 adapter/guardrail layer in Dart

### Final artifacts

| Artifact | Location/size |
| --- | --- |
| Merged Hugging Face model | `/Users/vashishtdevasani/Downloads/noteechoes-qwen25-core-v4-merged-hf`, about 3.10 GB |
| Deployable MLX model | `/Users/vashishtdevasani/Downloads/noteechoes-qwen25-core-v4-mlx-4bit` |
| MLX runtime files | 880,107,321 bytes, about 839 MiB |
| Main weights | 868,628,547 bytes |
| Main-weight SHA-256 | `4454aaa0b1cbddd255fb515c1172962672dab76778ba7469a9bf538ffca2c526` |
| Signed iOS release | `/Users/vashishtdevasani/Downloads/NoteEchoes-Core-v4-iOS-Release/Runner.app`, about 102 MiB on disk |

The final model uses 4-bit affine MLX quantization with group size 64. It remains below the requested 1–1.2 GB model limit.

## 8. Evaluation: honest interpretation

### Final MLX artifact

| Suite | Raw model exact row passes | Model + deterministic guardrails |
| --- | ---: | ---: |
| Locked release | 47/47 (100%) | 47/47 (100%) |
| Validation | 371/534 (69.5%) | 534/534 (100%) |
| Test | 384/543 (70.7%) | 543/543 (100%) |
| Challenge | 167/168 (99.4%) | 168/168 (100%) |
| Total | 969/1,292 (75.0%) | 1,292/1,292 (100%) |

The raw model maintained 100% normalized schema validity and language accuracy on validation/test, but its weaker raw metrics were action-kind selection, note-kind selection, and clarification. The challenge model missed one Romanized Telugu language label; the guardrail corrected `te` to `te-roman` when the text contained no Telugu script.

The `1,292/1,292` result is real for the tested product stack, but it must not be described as a perfect neural model. The deterministic rules recognize specific high-cost patterns:

- Negative task/reminder commands
- Brainstorm-only wording
- Calendar words incorrectly routed as reminders
- Ambiguous reminder times
- Romanized language-label correction
- Several trained combined task/reminder patterns
- Project-update and mind-dump preservation

These rules are tightly connected to known dataset wording. New spontaneous phrasing can still fail. A perfect result on a synthetic regression set does not prove perfect behavior in the real world.

### Evaluation discrepancy worth preserving

One Kaggle merged-Hugging-Face evaluation report recorded 11 failures on the 47-case release suite before the final artifact selection/local MLX evaluation. The final MLX report later recorded 47/47 raw passes. Backend, checkpoint, generation, or evaluation-iteration differences can produce this discrepancy. The shipping artifact's MLX reports are the relevant release evidence, but both records should remain available for audit.

## 9. Application integration

The application path is:

```text
microphone or typed input
  → Whisper/Apple transcription
  → Core v4 MLX generation at temperature 0
  → JSON extraction
  → deterministic Core v4 guardrails
  → Core v4-to-existing-domain adapter
  → date resolver and retrieval
  → user confirmation for side effects
  → existing NoteEchoes UI and storage
```

The adapter maps Core v4 into existing NoteEchoes objects, so the model did not require a UI rewrite. Tasks appear as action lists/checklists, reminders appear in the existing reminder-review flow, calendar proposals use the existing event flow, and notes retain the existing card/editor presentation.

If the MLX model is not loaded, the current provider can still fall back to the lightweight local categorization engine. That is not a generic foundation-model fallback, but it also does not provide the evaluated multilingual Core v4 behavior. The UI should continue to show clearly when Core v4 is unavailable.

## 10. Hugging Face distribution and iPhone installation

The public repository is:

`https://huggingface.co/Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit`

The iOS application is pinned to immutable commit:

`ab5704d40dc4096e7460fb10443e99fc891b7196`

The app verifies the exact size and SHA-256 of every required model/tokenizer file, requires 2 GB free space during installation, excludes the downloaded model from iCloud backup, and refuses to enable an invalid model.

The original background-session implementation crashed on physical iOS because the current Swift Hugging Face library used completion handlers with a background `URLSession`, which iOS forbids. The verified release therefore uses a foreground transfer and tells the user to keep NoteEchoes open for the one-time 839 MiB download. A delegate-based background downloader or compatible future library version is still desirable.

The signed release was installed on the connected iPhone 17 Pro Max, launched standalone, downloaded the model, verified it, loaded it into MLX, and displayed `Ready`.

## 11. Current supported scope

### Strongest intended path

- English, Telugu, Hindi, Romanized Telugu, and Romanized Hindi
- Notes, ideas, decisions, project updates
- Tasks and grounded checklists
- Reminders and calendar proposals
- Combined task/reminder phrasing covered by the guardrails
- Queries about saved notes when retrieval supplies relevant context

### Not established by this release

- Perfect spontaneous speech across accents/noise
- English or multilingual email/message/prompt generation through the Core v4 spoken-action path
- Reliable journal/meeting classification despite schema labels existing
- Background download after the app is terminated
- App Store/TestFlight distribution
- iPhone latency, peak memory, battery, and thermal benchmarks across supported devices
- Knowledge of the user's notes without retrieval context

## 12. Recommended next evidence before a consumer release

1. Create a frozen, human-authored set of real spontaneous speech from multiple native speakers.
2. Store both audio and transcription so ASR failures are separated from model failures.
3. Include at least 100 examples per major language/style and action family.
4. Add missing challenge coverage for queries and explicit multi-item checklists.
5. Decide whether English email/message/prompt generation is a separate model route or part of a future Core contract.
6. Measure cold load, first-token latency, full response latency, memory, thermals, and battery on multiple iPhone RAM tiers.
7. Add end-to-end Flutter → Swift → MLX device tests rather than only Python/Dart replay tests.
8. Collect opt-in corrections only; never train on private notes/audio by default.
9. Retrain only after real failure clusters are large enough to justify it. Continue adding deterministic rules only when they are general, auditable, and covered by tests.

## 13. Source locations

- Final pipeline: `/Users/vashishtdevasani/Downloads/NoteEchoes-model-pipeline-v4-core`
- Dataset audit: `ready/audit_report_v4.json`
- Dataset counts: `ready/dataset_report_v4.json`
- Schema: `schema/noteechoes_core_v4.schema.json`
- System prompt: `prompts/core_router_system_v4.txt`
- Training code: `training/train_qwen25_unsloth.py`
- Evaluation reports: `evaluation/`
- Historical review workbook: `/Users/vashishtdevasani/Downloads/Language Review Vashisht (1).xlsx`
- Historical archive: `/Users/vashishtdevasani/Downloads/Note Echoes Multilingual v2.zip`
- iOS integration handoff: `NOTECHOES_CORE_V4_IOS_HANDOFF.md`
