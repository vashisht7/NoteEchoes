# NoteEchoes Model and Checklist Recovery Plan

Last verified: 2026-08-23
Repository inspected: `/Users/vashishtdevasani/Desktop/Notechoes App`
Audience: the next implementation agent, the product owner, and future model-training agents

## 1. Executive conclusion

Do **not** start another Kaggle training run yet.

The current checklist failure is not proven to be a weak-model failure. Repository inspection found several application-integration faults that can make a good model appear not to work:

1. The iOS Action Button / Shortcut import path never calls the Core v4 model. It uses the old English keyword-and-bullet parser directly.
2. The legacy parser only creates checklist items from written lines beginning with `- [ ]`, `-`, `•`, or `1.`. Normal speech transcripts are generally one sentence and therefore produce no checklist.
3. The normal in-app voice path calls Core v4 only when the app believes the model is ready. Model loading or generation errors are silently caught and the note is saved with the legacy result. The user is not told that fallback occurred.
4. The normal voice path copies model-produced task items into `NoteModel.checklist`, but drops model-produced reminders and calendar events.
5. The v4 output has an `ask` clarification field, but `CoreActionV4Adapter` does not preserve it in `NoteAnalysisResult`, so the UI cannot ask the missing-time question.
6. The repository contains multiple interpretation stacks with overlapping responsibilities. Capture, Action Button ingestion, note analysis, multilingual interpretation, and voice search do not all pass through one orchestrator.
7. The model prompt says checklist `items` must be spoken, but does not precisely define how to split a naturally spoken list. Only 289 Core v4 training rows contain explicit checklist items, and the challenge split contains no explicit checklist-item rows. The perfect guarded release score therefore does not prove end-to-end checklist quality.

The correct recovery sequence is:

> unify every capture route → preserve the complete interpretation → render/review it → test on a physical device after relaunch → collect real failures → change prompt/guardrails → retrain only if the raw model still fails.

## 2. Product contract to preserve

The product vision is a private, speech-first memory and action application:

- A user can speak naturally in English, Telugu, Hindi, Romanized Telugu/Hindi, or mixed language.
- NoteEchoes preserves what was said as a durable note.
- It recognizes notes, ideas, decisions, project updates, tasks, multi-item checklists, reminders, calendar proposals, and saved-memory questions.
- A spoken checklist appears as tappable checklist rows in the existing UI.
- It never invents steps that were not spoken.
- It never claims a reminder or calendar event was created before the user confirms it and the operating system reports success.
- English is intended to support the complete action surface.
- Telugu and Hindi must support core capture, tasks/checklists, reminders, calendar proposals, and queries. Telugu/Hindi email and agent-prompt generation are not required.
- The downloadable local model must stay at or below approximately 1.2 GB. The current 4-bit model is about 839 MiB and fits this requirement.

Core v4 is an interpreter, not a general chatbot. Storage, retrieval, date resolution, confirmation, operating-system writes, and UI rendering belong to the application.

## 3. Current release facts

- Model family: Qwen2.5-1.5B-Instruct
- Product model: NoteEchoes Core v4, MLX 4-bit
- Public model: `https://huggingface.co/Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit`
- Pinned revision: `ab5704d40dc4096e7460fb10443e99fc891b7196`
- Local model folder: `/Users/vashishtdevasani/Downloads/noteechoes-qwen25-core-v4-mlx-4bit`
- Installed model size: approximately 839 MiB
- Main weights SHA-256: `4454aaa0b1cbddd255fb515c1172962672dab76778ba7469a9bf538ffca2c526`
- Dataset: 6,677 train, 534 validation, 543 test, 168 challenge
- Explicit checklist-item rows in train: 289
- Recorded raw MLX exact-row result: 969/1,292 (75.0%)
- Recorded guarded product replay: 1,292/1,292

The guarded score is useful, but it is dominated by known structured text cases. It is not a physical-microphone, transcription, persistence, and UI test. It must not be presented as proof that every spoken checklist works.

## 4. Actual repository flow

### 4.1 In-app microphone overlay

Current path:

```text
microphone
  → live speech / recorded audio
  → OfflineSpeechBridge transcription
  → SiriActionOverlay calls legacy analysis for its completion display
  → NoteService.createFromVoiceTranscription
      → legacy analysis first
      → Core v4 only if ModelAvailabilityService says Ready
      → load model if necessary
      → model JSON
      → CoreActionV4Guardrails
      → CoreActionV4Adapter
      → copy only title/summary/tags/actionItems
      → NoteModel.checklist
  → KeepTextNoteCard renders checklist when checklist is non-empty
```

Important files:

- `lib/widgets/siri_action_overlay.dart` — records/transcribes and calls `NoteService`; it separately shows a legacy analysis result.
- `lib/services/note_service.dart:173` — the main voice-note creation path.
- `lib/ai/infrastructure/qwen_llama_provider.dart:122` — generation, JSON parsing, guardrails, and adapter.
- `lib/ai/infrastructure/prompt_repository.dart:15` — current Core v4 system prompt.
- `lib/ai/domain/core_action_v4_adapter.dart:49` — task/checklist conversion.
- `lib/widgets/keep_text_note_card.dart:141` — checklist rendering based on `note.checklist.isNotEmpty`.

### 4.2 Action Button / Shortcuts

Current path:

```text
iOS Shortcut / Action Button
  → PendingVoiceNoteStore
  → ActionButtonNoteIngestionService
  → AiCategorizationEngine only
  → NoteModel
  → UI
```

`lib/services/action_button_note_ingestion_service.dart:80` calls the legacy analyzer directly. It never calls `NoteService.createFromVoiceTranscription`, Core v4, its prompt, its adapter, or its guardrails.

This is a confirmed route mismatch.

### 4.3 Legacy checklist behavior

`lib/services/ai_categorization_engine.dart:227` splits the text by newline and extracts items only when a line starts with a checkbox, bullet, or number. It returns `NoteContentType.textOnly` at line 263.

This input works for the legacy parser:

```text
Shopping list
- [ ] Milk
- [ ] Eggs
- [ ] Bread
```

This normal speech transcript does not become a legacy checklist:

```text
Make a shopping checklist with milk, eggs, and bread.
```

### 4.4 Reminder/calendar path

`CoreActionV4Adapter` creates `actionItems`, `events`, and `reminders`. However, `NoteService.createFromVoiceTranscription` only copies `actionItems` to `NoteModel.checklist`. It does not stage `events` or `reminders` through `ExtractActionsUseCase`.

`lib/ai/application/extract_actions_use_case.dart` can stage suggestions for confirmation, but repository search found no capture call site using it. The implementation exists without being connected to voice-note creation.

### 4.5 Saved-memory questions

The conversational voice assistant uses `HybridRetrievalService` and is distinct from voice-note capture. A Core v4 `mode=query` result sent through `createFromVoiceTranscription` is still stored as a note. Routing must happen before persistence: queries go to grounded retrieval; captures go to storage.

### 4.6 Competing interpretation systems

The repository currently has all of these:

- `AiCategorizationEngine` — old deterministic English-heavy categorizer
- `QwenLlamaProvider.generateNoteAnalysis` — Core v4 path
- `MultilingualInterpretationService` — a separate, broader JSON schema
- `AnalyzeNoteUseCase` — cached/background analysis path
- `VoiceAssistantService` — saved-note retrieval and response path
- `ActionButtonNoteIngestionService` — direct legacy path

The next agent must not add a sixth interpretation route. Create one application-level orchestrator and make every capture entry point call it.

## 5. Root-cause ranking

| Priority | Finding | Confidence | User-visible effect |
| --- | --- | ---: | --- |
| P0 | Action Button bypasses Core v4 | Confirmed | Spoken checklist becomes plain note |
| P0 | Legacy parser requires written list markers | Confirmed | One-sentence ASR transcript yields zero checklist items |
| P0 | Reminder/event outputs are dropped during voice save | Confirmed | Model recognizes action but app does not show/execute review flow |
| P0 | Fallback is silent | Confirmed | Failure looks like bad intelligence rather than model/load error |
| P1 | `ask` clarification is dropped | Confirmed | Missing time cannot be clarified safely |
| P1 | Query and capture routing is fragmented | Confirmed | Some questions may be stored instead of answered |
| P1 | Checklist splitting rule is underspecified | Confirmed in prompt; runtime impact must be measured | List may become one task or lose items |
| P1 | Grounding filter may reject paraphrased or ASR-normalized items | Confirmed in code; frequency unknown | Model emits items but adapter removes them |
| P2 | Training coverage for explicit checklists is thin | Confirmed from dataset report | Model generalization risk after integration is fixed |

## 6. Target architecture

Create one `SpokenCaptureOrchestrator` (name may vary, responsibility may not) and return one complete product result.

```text
all inputs
  ├─ in-app microphone
  ├─ Action Button / Shortcut queue
  ├─ typed quick capture
  └─ imported transcript
          ↓
TranscriptEnvelope
  raw text + ASR language + source + timestamp
          ↓
SpokenCaptureOrchestrator
  1. validate text
  2. refresh model availability
  3. load pinned model idempotently
  4. run exact versioned prompt
  5. parse strict JSON
  6. normalize with deterministic guardrails
  7. preserve diagnostics/provenance
  8. route query versus capture
          ↓
CaptureInterpretation
  ├─ note fields
  ├─ checklist items
  ├─ reminder proposals
  ├─ calendar proposals
  ├─ clarification question
  ├─ query terms
  └─ engine/model/prompt/schema versions
          ↓
Product transaction
  ├─ persist note + checklist atomically
  ├─ stage actions for confirmation
  ├─ show clarification
  └─ run retrieval for query
```

### Required invariants

1. Every capture source uses the same orchestrator.
2. The original transcript is always preserved, even if interpretation fails.
3. A ready local model is loaded explicitly before generation.
4. A model failure is recorded and visible; it is not disguised as success.
5. Checklist items are grounded in the transcript and retain spoken order.
6. A reminder/calendar proposal is never silently discarded or automatically committed.
7. Query mode is never persisted as a new memory unless the user explicitly asks to save the question.
8. The saved note records `modelRevision`, `modelVersion`, `promptVersion`, `schemaVersion`, `engine`, and fallback reason for debugging.

## 7. Recommended product schema

Do not force the trained v4 model to emit an entirely new schema before integration is repaired. Use two layers:

1. **Neural wire format:** retain Core v4 JSON for the existing model.
2. **Application domain format:** introduce a complete `CaptureInterpretation` that preserves every v4 field plus provenance.

Suggested application type:

```json
{
  "schema_version": 1,
  "route": "capture",
  "language": "en",
  "memory_kind": "task_list",
  "title": "Weekend shopping",
  "summary": "Buy milk, eggs, bread, and coffee",
  "checklist": [
    {"text": "milk", "evidence": "milk", "completed": false},
    {"text": "eggs", "evidence": "eggs", "completed": false},
    {"text": "bread", "evidence": "bread", "completed": false},
    {"text": "coffee", "evidence": "coffee", "completed": false}
  ],
  "reminder_proposals": [],
  "calendar_proposals": [],
  "clarification": null,
  "query_terms": [],
  "provenance": {
    "engine": "core_v4_mlx",
    "model_revision": "ab5704d40dc4096e7460fb10443e99fc891b7196",
    "prompt_version": "v4.1-checklist",
    "fallback_reason": null
  }
}
```

`NoteModel.contentType` does not need a new enum value for the current cards: the UI already renders a checklist whenever `note.checklist` is non-empty. A future migration may add an explicit presentation type, but it is not required to fix the immediate bug.

## 8. Model system prompt: proposed Core v4.1

Prompt changes must be evaluated against the pinned model before shipping. Small models are sensitive to prompt distribution changes. The next agent should add this as a second prompt constant, run the locked suite plus the new checklist suite, and only then replace v4.0.

```text
You are the private on-device NoteEchoes core interpreter.

Convert the user's exact utterance into one compact JSON object. Output JSON only, with no markdown and no explanation.

Use exactly these keys in this order:
v, language, mode, kind, title, summary, actions, query_terms, ask.

Rules:
- v is 4.
- Preserve the user's English, Telugu, Hindi, Romanized, or mixed-language style.
- mode=capture for information the user wants remembered or acted on.
- mode=query only when the user asks about previously saved notes or memories.
- kind is note, idea, decision, project_update, journal, meeting, task_list, or none.
- Use kind=task_list when the user requests one or more tasks or a checklist.
- actions may contain only task, reminder, or calendar_event.
- Every action has exactly: kind, text, items, date, time, people, place.
- For a task list, text is a short grounded label for the list.
- Put each independently spoken checklist item into items, in spoken order.
- Split explicit enumeration such as "first... second...", numbered items, pauses represented by commas/semicolons, or a list introduced by "these items".
- Split a phrase joined by "and/also/then" only when both sides are independently actionable items.
- Do not split a single action merely because its object contains "and".
- Do not invent prerequisites, workflow steps, or completion/verification steps.
- If the user requests a checklist but states only one task, return that one spoken task in items.
- If no checklist item or task is spoken, use items=[].
- text and every item must be supported by words in the utterance; light cleanup of filler is allowed, changing meaning is not.
- Keep relative dates and times exactly as spoken. Do not calculate them.
- The app asks for confirmation before reminders or calendar writes.
- If a reminder or calendar request lacks an executable date or time, put one short question in ask in the user's language.
- For a saved-memory query, use mode=query, kind=none, title=null, summary=null, actions=[], and grounded query_terms.
- Email, message, and agent-prompt generation are outside this core model. Store those as a normal note with no actions.
- Use null for missing title, summary, date, time, place, or ask. Use [] for empty lists.
- Never claim an action was completed, sent, scheduled, or saved.
```

### Do not add few-shot examples to the production system prompt immediately

The 1.5B model was trained with a particular prompt/input distribution. Long examples increase latency and may reduce schema reliability. First test the clarified zero-shot prompt above. If examples are necessary, use at most one compact positive checklist example and one negative/non-invention example, then re-run every release gate.

## 9. How the application must prompt the model

The application should send exactly two chat messages:

```text
SYSTEM: <versioned Core v4.1 prompt>
USER: <raw transcription only>
```

Requirements:

- Do not prepend `Note Content:`, language explanations, IDs, timestamps, or UI instructions to the user message.
- Do not normalize away commas, conjunctions, or enumeration words before model inference.
- Use temperature `0.0`.
- Keep structured maximum tokens at 1,024 until measured output shows a safe lower ceiling.
- Parse the first complete JSON object, validate all enum and field types, then apply guardrails.
- Reject or repair malformed output explicitly; do not reinterpret arbitrary prose as successful JSON.
- Record raw model output in local debug diagnostics only, never analytics containing user note text.
- The native MLX chat template and the Dart message format must remain covered by a golden test.

## 10. How the user should speak

Natural speech should work, but explicit list framing gives the most reliable result while Core v4.1 is being validated.

### English

```text
Create a checklist with these items: buy milk, call Ravi, submit the expense report, and charge the laptop.
```

Expected checklist:

1. Buy milk
2. Call Ravi
3. Submit the expense report
4. Charge the laptop

```text
My tasks are: first send the design to Maya; second review the build; third book the meeting room.
```

### Telugu

```text
ఈరోజు చెక్‌లిస్ట్‌లో ఇవి పెట్టు: పాలు కొనాలి, రవికి కాల్ చేయాలి, రిపోర్ట్ పంపాలి.
```

Expected items are the three spoken actions in the same order.

```text
నా పనులు: మొదట బిల్లు కట్టాలి, తర్వాత మందులు కొనాలి, ఆపై అమ్మకు ఫోన్ చేయాలి.
```

### Romanized Telugu

```text
Checklist lo ee items pettu: paalu konaali, Ravi ki call cheyyali, report pampali.
```

### Hindi

```text
आज की चेकलिस्ट में ये चीज़ें डालो: दूध खरीदना, रवि को कॉल करना, रिपोर्ट भेजना।
```

```text
मेरे काम हैं: पहले बिल भरना, फिर दवाई खरीदना, उसके बाद माँ को फोन करना।
```

### Romanized Hindi

```text
Checklist mein ye items dalo: doodh kharidna, Ravi ko call karna, report bhejna.
```

### Single task

```text
Add submit the tax form to my task list.
```

This should create one tappable checklist row. The app must not invent subtasks such as finding documents or verifying submission.

### Task plus reminder

```text
Add send the proposal to my tasks and remind me tomorrow at 9 AM.
```

Expected product behavior:

- One checklist item: `send the proposal`
- One reminder proposal
- A confirmation card before the operating-system write

### Avoid while diagnosing

These phrases are ambiguous and should not be the primary acceptance tests:

```text
Do the shopping stuff.
Handle everything for launch.
Make a perfect checklist for my project.
```

NoteEchoes must preserve them as a note or one grounded task; it must not invent a useful-looking plan.

## 11. Implementation plan for the next agent

### Phase 0 — preserve and baseline

1. Read this file plus:
   - `NOTECHOES_CORE_V4_IOS_HANDOFF.md`
   - `NOTECHOES_MODEL_DATASET_AND_PREPARATION.md`
   - `NOTECHOES_SPEAKING_GUIDE.md`
   - `NOTECHOES_SENIOR_ENGINEERING_ASSESSMENT.md`
2. Inspect `git status` before editing. The worktree already contains user-owned and previous-agent changes. Do not reset, discard, or broadly reformat them.
3. Preserve the pinned Hugging Face revision and SHA validation.
4. Add baseline failing tests before changing behavior.

Baseline fixtures must include:

- English, Telugu, Hindi, Romanized Telugu, and Romanized Hindi multi-item lists
- one-item task
- task plus reminder
- list with a compound object that must not be incorrectly split
- negative command: “this is only an idea, do not make tasks”
- app relaunch with model installed but provider not yet loaded
- simulated generation error
- Action Button import and in-app microphone paths

### Phase 1 — one interpretation orchestrator

1. Add `lib/ai/application/spoken_capture_orchestrator.dart`.
2. Inject interfaces for model availability, generation, storage, retrieval routing, and suggested-action staging so tests can use fakes.
3. Move the following sequence into it:
   - availability refresh
   - idempotent model load
   - model generation
   - schema validation
   - v4 guardrails
   - adapter/domain mapping
   - diagnostics/provenance
4. Return a result; do not persist inside the low-level provider.
5. Make `NoteService.createFromVoiceTranscription` delegate to the orchestrator.
6. Make `ActionButtonNoteIngestionService` delegate to the same orchestrator while preserving the durable acknowledge-after-commit behavior.
7. Make the Siri overlay show the actual orchestration result, not a separate legacy analysis.

### Phase 2 — preserve every model output

1. Introduce `CaptureInterpretation` or extend the domain safely to retain:
   - route/mode
   - memory kind
   - checklist items
   - reminders
   - calendar events
   - clarification question (`ask`)
   - query terms
   - provenance and fallback reason
2. Map checklist items to `NoteModel.checklist` in spoken order.
3. Stage reminders and events using `ExtractActionsUseCase` and show `SuggestedActionsReview`.
4. Show `ask` as a localized clarification prompt before saving an incomplete action.
5. Route `mode=query` to the grounded voice assistant instead of saving it as a new note.
6. Keep note persistence and pending-action staging transactional or recoverable.

### Phase 3 — make fallback honest and useful

1. Replace broad silent catches with typed failure states:
   - model not installed
   - integrity verification failed
   - load failed
   - generation failed
   - invalid JSON/schema
   - timeout/resource pressure
2. Preserve the transcript immediately so speech is never lost.
3. Show a small status such as “Saved note; local intelligence was unavailable” with Retry.
4. If the legacy fallback remains, teach it deterministic explicit list phrases across supported languages, but label its engine in provenance. It is a resilience layer, not the primary intelligence.
5. Do not report a fallback-produced plain note as successful checklist interpretation.

### Phase 4 — prompt v4.1 experiment

1. Add the proposed prompt as `coreActionV41SystemPrompt` without deleting v4.0.
2. Give it an explicit `promptVersion`.
3. Run both prompts against the same frozen raw-model suite.
4. Add checklist-specific metrics:
   - list intent accuracy
   - item exact match after conservative normalization
   - item precision and recall
   - spoken-order accuracy
   - hallucinated-item rate
   - single-task retention
   - non-list false-positive rate
5. Promote v4.1 only if it improves checklist metrics without regressing schema, negative commands, languages, reminders, calendar events, and queries.

### Phase 5 — end-to-end evaluation

Test the product pipeline, not only JSON files.

For every fixture, assert:

1. input route reached the orchestrator;
2. expected engine/model/prompt version was recorded;
3. `NoteModel.checklist` has the expected number and order of items;
4. saved JSON round-trips without data loss;
5. the home card renders checkbox widgets and item text;
6. toggling a checkbox persists after relaunch;
7. reminders/events appear in review and are not committed before confirmation;
8. clarification is visible when required;
9. a query is answered from saved notes, not stored as a note;
10. failure preserves the transcript and exposes Retry.

Run at minimum:

```text
flutter test test/ai/core_action_v4_adapter_test.dart
flutter test test/ai/prompt_repository_test.dart
flutter test test/spoken_capture_orchestrator_test.dart
flutter test test/action_button_ingestion_test.dart
flutter test test/checklist_capture_widget_test.dart
flutter test integration_test/iphone_behavior_test.dart -d <physical-device-id>
```

Use actual filenames created by the implementation if they differ. Do not claim completion from unit tests alone.

### Phase 6 — physical-device acceptance

Run the following after a cold app launch, not only immediately after downloading/loading the model:

1. Confirm model Settings says Ready.
2. Force-close and reopen NoteEchoes.
3. Speak one checklist in each supported language style.
4. Repeat the same cases through the Action Button / Shortcut.
5. Confirm visible checklist rows and item order.
6. Toggle an item, close the app, reopen, and confirm persistence.
7. Test task plus reminder and reject the reminder once.
8. Test a saved-memory question and confirm it does not create a note.
9. Capture diagnostics showing the exact model revision and prompt version, without uploading note text.

### Phase 7 — decide whether Core v5 training is justified

Retrain only when all integration tests pass and the pinned raw model still fails a frozen, human-reviewed checklist set.

Trigger for retraining:

- at least 100 real or carefully human-written checklist utterances per major language style;
- failures reproduced at temperature 0 with the exact production prompt/template;
- failures attributable to raw model JSON rather than ASR, routing, parsing, grounding, storage, or UI;
- a frozen test set that is never included in training.

## 12. Core v5 dataset plan, only if Phase 7 triggers

### Data composition

Create a focused checklist/action increment instead of regenerating the entire dataset:

- 40% multi-item explicit checklists
- 15% single tasks
- 10% task plus reminder/calendar combinations
- 10% natural conjunction and pause-based lists
- 10% negative/non-action statements
- 5% ambiguous requests requiring clarification
- 5% ASR-like punctuation loss and mild transcription errors
- 5% long mind dumps containing zero or one actionable item

Balance English, Telugu, Hindi, Romanized Telugu, Romanized Hindi, and realistic code-mixing. Use real user-authored phrasing with consent or native-speaker-authored examples. Do not treat AI-preapproved synthetic rows as human validation.

### Checklist labels

Each example must label:

- whether a checklist is requested;
- exact grounded item spans;
- normalized display text;
- item order;
- whether conjunction means two actions or one compound object;
- whether a reminder/event is separate from the task;
- expected clarification;
- language/script style;
- expected route: capture or query.

### Split rules

- Split by semantic template family, not random row, to prevent paraphrase leakage.
- Keep speakers/scenarios separate when real voice data exists.
- Freeze test and adversarial challenge files before training.
- Deduplicate normalized text and high-similarity paraphrases across splits.
- Require human review of every validation/test/challenge example.

### Training strategy

- Warm-start from the current best Core v4 adapter/merged model.
- Keep Qwen2.5-1.5B and 4-bit delivery unless an evidence-backed comparison beats it within the size budget.
- Train a small focused LoRA increment first; do not repeat a full broad run.
- Use completion-only masking, sequence length 1,024, deterministic seed, checkpoints, and evaluation at fixed intervals.
- Select by a composite product metric, not training/evaluation loss alone.
- Evaluate the merged Hugging Face model and final MLX 4-bit conversion separately.
- Reject a candidate if quantization materially reduces checklist item recall or increases hallucinations.

### Release gate

Suggested minimum gates:

| Metric | Required |
| --- | ---: |
| Valid JSON/schema | 100% |
| Checklist intent accuracy | ≥ 97% |
| Checklist item precision | ≥ 98% |
| Checklist item recall | ≥ 95% |
| Hallucinated item rate | ≤ 0.5% |
| Item order accuracy | ≥ 98% |
| Negative-command safety | 100% on locked challenge |
| Reminder/calendar confirmation safety | 100% |
| End-to-end checklist UI pass | 100% on locked physical-device suite |

Language metrics must be reported separately; a high aggregate score must not hide weak Telugu, Hindi, or Romanized behavior.

## 13. Tests missing from the current repository

The existing adapter test proves that a hand-authored Telugu v4 JSON object maps to two `ActionItem`s. It does not prove that:

- the model produces that JSON from speech;
- the Action Button reaches the model;
- the provider loads after an app relaunch;
- the note saves the items;
- the card renders them;
- the items persist after relaunch;
- a reminder or calendar output reaches the confirmation UI.

The existing `NoteService` test only checks that an idea note is saved with a title/category. It does not exercise a ready native model or checklist output.

These gaps are why previous model evaluation and the current user experience can disagree.

## 14. File-by-file change map

| File | Required change |
| --- | --- |
| `lib/ai/application/spoken_capture_orchestrator.dart` | New single capture/query orchestration boundary |
| `lib/services/note_service.dart` | Delegate interpretation; save complete result; stop silently discarding actions |
| `lib/services/action_button_note_ingestion_service.dart` | Replace direct legacy call with orchestrator; retain durable queue acknowledgement |
| `lib/widgets/siri_action_overlay.dart` | Display actual orchestration result/status, not separate legacy analysis |
| `lib/ai/infrastructure/qwen_llama_provider.dart` | Strict loaded path, typed diagnostics, strict schema/version handling |
| `lib/ai/infrastructure/prompt_repository.dart` | Add and version v4.1 prompt experiment |
| `lib/ai/domain/core_action_v4_adapter.dart` | Preserve clarification/query metadata; improve evidence mapping without permitting invention |
| `lib/ai/domain/core_action_v4_guardrails.dart` | Add only measured deterministic corrections; remove dataset-phrase overfitting over time |
| `lib/ai/domain/note_analysis.dart` or new domain file | Represent complete interpretation and provenance |
| `lib/ai/application/extract_actions_use_case.dart` | Connect to capture result and confirmation UI |
| `lib/widgets/keep_text_note_card.dart` | Likely no structural change; add widget tests and fallback status if designed |
| `lib/models/note_model.dart` | Add provenance/status only through backward-compatible serialization |
| `test/...` | Add orchestrator, every-entrypoint, persistence, widget, and failure-state tests |
| `integration_test/iphone_behavior_test.dart` | Add cold-launch physical checklist flows |

## 15. Definition of done

The work is complete only when all of the following are true:

- In-app mic and Action Button use the same Core v4 path.
- A cold-launched app with the installed model creates visible multi-row checklists in all five language styles.
- Single tasks create one checklist row without invented subtasks.
- Reminder/calendar outputs reach user confirmation.
- Missing required time produces a visible clarification question.
- Saved-memory questions route to grounded retrieval and are not saved as notes.
- Model/load/schema failures preserve the transcript and show an honest status with Retry.
- Checklist toggles persist after app restart.
- Every result records model revision, prompt version, schema version, engine, and fallback reason.
- Raw-model, guarded-parser, service, persistence, widget, and physical-device results are reported separately.
- No new Kaggle training is started unless the frozen real-world suite proves a remaining raw-model defect.
- The final MLX model remains within the agreed download budget and its immutable revision and hashes are verified.

## 16. What the next agent must not do

- Do not launch another training run as the first response to the checklist bug.
- Do not delete or reset the current dirty worktree.
- Do not replace the pinned model with mutable Hugging Face `main`.
- Do not put a Hugging Face token in the app, repository, logs, or this document.
- Do not make the model invent checklist steps to appear intelligent.
- Do not auto-create reminders/events without confirmation.
- Do not call the legacy analyzer directly from a product capture entry point.
- Do not call a guarded replay score “raw model accuracy.”
- Do not declare success from JSON evaluation without verifying persistence and visible UI on the physical iPhone.

## 17. Recommended first implementation ticket

**Title:** Route all spoken captures through one tested Core v4 orchestrator

**Acceptance criteria:**

1. Action Button and in-app mic call the same injected orchestration service.
2. A fake Core v4 response containing three task items saves three `CheckListItem`s through both routes.
3. A fake reminder/event response is staged for confirmation rather than dropped.
4. A fake `ask` value reaches a visible clarification state.
5. A simulated load/generation error saves the transcript, records fallback reason, and exposes Retry.
6. Tests assert no direct `AiCategorizationEngine.analyzeNote` call remains in capture entry points.
7. No training, model replacement, or schema-breaking migration is part of this ticket.

Completing this ticket will determine whether the current model is actually deficient. Until then, retraining would spend GPU time while leaving the confirmed application routing defects in place.
