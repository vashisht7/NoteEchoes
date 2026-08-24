# The NoteEchoes Model Book

**A readable guide to the model you created, why it exists, how it was trained, how the app calls it, and what it can honestly do**

Last verified: 2026-08-24  
Shipping model: NoteEchoes Core v4  
Base family: Qwen2.5-1.5B-Instruct  
Deployment format: Apple MLX 4-bit  

---

## 1. The idea in one sentence

NoteEchoes Core v4 is a small, private, on-device language interpreter that turns natural English, Telugu, Hindi, and Romanized speech into structured note, checklist, reminder, calendar, project, idea, decision, or memory-query data that the NoteEchoes application can safely execute.

It is not intended to be a general-purpose chatbot. The model understands the user's words and proposes structure. The application owns storage, safety, dates, confirmations, Apple integrations, and presentation.

## 2. The product vision behind the model

The application should let someone speak the small things occupying their mind:

- “Remember that the contractor prefers calls after five.”
- “First verify the model, second test the app.”
- “Remind me tomorrow at nine to call Amma.”
- “Schedule the design review next Monday at three.”
- “The launch is delayed because the icons are unfinished.”
- “How many items from my release checklist are still pending?”

Those sentences should become durable, useful objects—not a block of unstructured transcript text.

The desired experience is:

```text
natural speech
  → language and intent understanding
  → structured action proposal
  → deterministic safety checks
  → NoteEchoes domain objects
  → note/checklist/reminder/event/query UI
  → durable local memory
```

The model is one component of that experience. Product quality comes from the complete chain.

## 3. Why the first model was replaced

### Qwen3 0.6B experiment

The early Unsloth experiment used `mlx-community/Qwen3-0.6B-4bit`. It was attractive because it was only about 351 MB, and its displayed training loss reached approximately `0.0031`.

That number was misleading as a product-quality signal:

- No evaluation dataset was configured in the displayed run.
- A low training loss can represent memorization.
- English appeared usable in manual testing.
- Telugu and Hindi did not consistently produce the required actions.
- There was no locked validation/test/challenge gate for the shipping artifact.

### Qwen2.5 v3 experiments

The 1.5B Qwen2.5 family gave the model more language capacity, but an earlier v3 comparison passed roughly `915/1,550` checks, or 59%. Combined actions, multilingual routing, negative commands, clarification, and stable output shape were still weak.

### Core v4 strategy

Core v4 did not simply “train longer.” It made the job narrower and clearer:

1. Use one compact JSON contract.
2. Remove draft-writing and coding-prompt generation from the multilingual core.
3. Focus training on notes, ideas, decisions, project updates, tasks, checklists, reminders, events, and saved-memory queries.
4. Add deterministic guardrails for failures that could create the wrong real-world action.
5. Evaluate the same 4-bit MLX artifact used in the application.

This is why the new system is stronger without exceeding the 1–1.2 GB model budget.

## 4. What exactly was trained

### Base model

The final model is based on `Qwen2.5-1.5B-Instruct`.

Training loaded the 4-bit Unsloth form and applied LoRA/QLoRA-style fine-tuning. The final adapter was merged into a Hugging Face model and converted to native Apple MLX 4-bit weights.

### Final Core v4 dataset

The final prepared dataset is located at:

```text
/Users/vashishtdevasani/Downloads/NoteEchoes-model-pipeline-v4-core/ready
```

| Split | Rows | Capture | Query |
| --- | ---: | ---: | ---: |
| Train | 6,677 | 6,607 | 70 |
| Validation | 534 | 499 | 35 |
| Test | 543 | 508 | 35 |
| Challenge | 168 | 168 | 0 |
| Total | 7,922 | 7,782 | 140 |

The audit recorded zero overlap between all pairs of splits.

### Training-language balance

| Language style | Rows | Share |
| --- | ---: | ---: |
| English | 1,260 | 18.9% |
| Hindi native/mixed | 1,953 | 29.3% |
| Romanized Hindi | 716 | 10.7% |
| Telugu native/mixed | 2,021 | 30.3% |
| Romanized Telugu | 727 | 10.9% |

### Important action coverage

The training split contains:

- 2,183 reminder actions
- 1,656 task actions
- 1,009 calendar-event actions
- 289 rows containing explicit checklist items
- 593 ideas
- 370 decisions
- 596 project updates
- 3,392 general notes
- 70 saved-memory queries

Core v4 conversion intentionally skipped 784 agent-prompt examples and 1,533 draft examples. That is a deliberate product decision, not an accidental missing feature.

### Historical multilingual review pack

The older multilingual review workbook contains 12,360 rows across native, mixed-script, and Romanized Telugu/Hindi. All rows are marked approved, but sampled reviewer metadata says `ai_preapproved`, with zero human corrections recorded.

This means the dataset has useful breadth but is still heavily synthetic. It must not be described as 12,360 independently human-verified natural utterances.

## 5. The model's language

The model does not answer with free-form prose. It returns exactly one JSON object with these ordered keys:

```text
v, language, mode, kind, title, summary, actions, query_terms, ask
```

### Main enums

```text
language: en | te | hi | te-roman | hi-roman | unknown
mode:     capture | query
kind:     note | idea | decision | project_update |
          journal | meeting | task_list | none
action:   task | reminder | calendar_event
```

Each action contains:

```text
kind, text, items, date, time, people, place
```

### Example: natural checklist

User:

```text
First check whether the model works correctly, second verify the app UI.
```

Conceptual response:

```json
{
  "v": 4,
  "language": "en",
  "mode": "capture",
  "kind": "task_list",
  "title": "Model and App Checks",
  "summary": "Verify the model and application UI.",
  "actions": [
    {
      "kind": "task",
      "text": "Complete the verification checklist",
      "items": [
        "Check whether the model works correctly",
        "Verify the app UI"
      ],
      "date": null,
      "time": null,
      "people": [],
      "place": null
    }
  ],
  "query_terms": [],
  "ask": null
}
```

### Example: reminder

```text
Remind me tomorrow at 9 AM to call Amma.
```

The model proposes a reminder action. The application resolves the relative date, requests Apple Reminders permission, creates the Apple Reminder, and schedules the local Lock Screen notification. The model itself cannot claim that iOS successfully created it.

### Example: missing information

```text
Remind me later to submit the form.
```

The correct result contains the reminder idea but asks what time it should be scheduled. “Later” must not silently become an invented time.

## 6. Training configuration

| Setting | Final value |
| --- | --- |
| Base | Qwen2.5-1.5B-Instruct |
| Method | LoRA/QLoRA-style 4-bit Unsloth training |
| Epochs | 1 |
| Maximum sequence | 1,024 tokens |
| Packing | Off |
| Completion-only masking | On |
| Seed | 3407 |
| LoRA rank | 32 |
| LoRA alpha | 64 |
| LoRA dropout | 0.05 |
| rsLoRA | On |
| Target modules | q/k/v/o and gate/up/down projections |
| Train batch | 1 |
| Gradient accumulation | 16 |
| Effective batch | 16 |
| Warm-start learning rate | 2e-5 |
| Optimizer | AdamW 8-bit |
| Scheduler | Cosine |
| Evaluation/checkpoint interval | 100 steps |
| Early stopping | Patience 4, threshold 0.0005 |

The final run used approximately 418 optimizer steps. It resumed after checkpoint 100 and selected checkpoint 200 as the best checkpoint.

Final recorded metrics:

- Successful trainer runtime: 3,949.8 seconds, about 65.8 minutes
- Training loss: `0.00464735174792235`
- Best evaluation loss: `0.02372388355433941`
- Best checkpoint: `checkpoint-200`

The total Kaggle GPU time was higher because it includes failed and superseded experiments.

## 7. The files that came out of training

### Merged Hugging Face model

```text
/Users/vashishtdevasani/Downloads/noteechoes-qwen25-core-v4-merged-hf
```

Approximate size: 3.10 GB. This is useful for conversion and research, but it is too large for the intended mobile product.

### Shipping MLX model

```text
/Users/vashishtdevasani/Downloads/noteechoes-qwen25-core-v4-mlx-4bit
```

- Quantization: MLX 4-bit affine, group size 64
- Total runtime size: 880,107,321 bytes, about 839 MiB
- Main weights: `model.safetensors`, 868,628,547 bytes
- Main-weight SHA-256: `4454aaa0b1cbddd255fb515c1172962672dab76778ba7469a9bf538ffca2c526`

### Public distribution

Repository:

```text
https://huggingface.co/Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit
```

Pinned immutable revision:

```text
ab5704d40dc4096e7460fb10443e99fc891b7196
```

The application never trusts mutable `main`. It downloads the pinned revision and checks exact file sizes and SHA-256 hashes before enabling inference.

## 8. Honest evaluation

| Suite | Raw MLX model | Model + Dart guardrails |
| --- | ---: | ---: |
| Locked release | 47/47 | 47/47 |
| Validation | 371/534 | 534/534 |
| Test | 384/543 | 543/543 |
| Challenge | 167/168 | 168/168 |
| Total | 969/1,292 (75.0%) | 1,292/1,292 (100%) |

The correct interpretation is:

- The raw neural model is not perfect.
- It is very good at producing valid schema and language labels.
- It is less reliable at some action-kind, note-kind, and clarification choices.
- The tested product stack passes because deterministic guardrails correct known high-cost patterns.
- The 100% product-stack score applies to this frozen, mainly synthetic regression suite—not every sentence a real person can speak.

One older merged-Hugging-Face evaluation recorded 11 failures on the 47-case release suite, while the selected local MLX artifact later passed 47/47 raw. Backend, checkpoint, generation, and evaluation revisions can explain this discrepancy. Both records should remain available for audit.

## 9. What the guardrails do

The main guardrail file is:

```text
lib/ai/domain/core_action_v4_guardrails.dart
```

It corrects a deliberately small set of dangerous or common ambiguities:

- Explicit “do not create” language
- Brainstorm-only statements
- “Remember this, but do not schedule anything”
- Calendar requests incorrectly labeled as reminders
- Vague reminder times
- Romanized-language labels
- Known combined task-plus-reminder patterns
- Project-update preservation
- Mixed mind dumps that should remain notes

The adapter is:

```text
lib/ai/domain/core_action_v4_adapter.dart
```

It maps v4 JSON into existing Dart objects such as `ActionItem`, `Reminder`, and `CalendarEvent`. It also rejects invented checklist items that are not grounded in the user's actual speech.

## 10. The model API inside Dart

This model is not an HTTP service. Its “API” is a local Dart-to-Swift boundary.

### Recommended product-level call

```dart
final note = await NoteService().createFromVoiceTranscription(spokenText);
```

Use this for normal captures. It performs validation, model readiness checks, title cleanup, checklist grounding, reminder handling, persistence, indexing, and UI notification.

### Lower-level structured interpretation

```dart
await ModelAvailabilityService.instance.refresh();
if (!ModelAvailabilityService.instance.qwen.isReady) {
  throw StateError('Download NoteEchoes Core v4 first.');
}

final provider = QwenLlamaProvider.instance;
if (!provider.isLoaded) await provider.load();

final result = await provider.generateNoteAnalysis(
  spokenText,
  noteId: 'capture-${DateTime.now().microsecondsSinceEpoch}',
  noteCreatedAt: DateTime.now(),
);
```

Use this when a caller needs to review `actionItems`, `reminders`, or `events` before saving.

### Raw local generation

```dart
final text = await QwenLlamaProvider.instance.generate(
  messages,
  options: GenerationOptions.structured,
);
```

The provider invokes the iOS channel:

```text
noteechoes/mlx_text_generation
```

Swift handles model download, verification, loading, token generation, cancellation, and status. Dart owns prompts, JSON extraction, domain mapping, and product rules.

### Important API files

| File | Responsibility |
| --- | --- |
| `lib/ai/infrastructure/qwen_llama_provider.dart` | Dart model provider and JSON parsing |
| `lib/ai/infrastructure/prompt_repository.dart` | Versioned system/user prompts |
| `lib/ai/domain/core_action_v4_guardrails.dart` | Deterministic corrections |
| `lib/ai/domain/core_action_v4_adapter.dart` | Maps v4 JSON to app objects |
| `lib/ai/infrastructure/model_availability_service.dart` | Ready/missing/repair state |
| `ios/Runner/MLXTextGenerationService.swift` | Native MLX download, integrity, load, generation |
| `lib/services/note_service.dart` | Product-level capture and persistence |

## 11. How to speak to the model

The best input is natural and explicit. Do not translate normal speech into command syntax.

### Plain note

```text
The blue onboarding screen feels calmer than the red version.
```

### Checklist

```text
Create a checklist. First verify the model, second test the app, third review the notifications.
```

### Reminder

```text
Remind me tomorrow at 8:30 AM to send the report.
```

### Calendar event

```text
Schedule a product review with Maya next Monday at 3 PM in the design room.
```

### Project update

```text
NoteEchoes update: the MLX model is installed, but Lock Screen acceptance testing remains.
```

### Saved-memory question

```text
What did I decide about the onboarding colors?
```

The query path must retrieve relevant saved notes. The model cannot know private notes merely because it was fine-tuned for NoteEchoes.

## 12. Supported and unsupported scope

### Strongest current scope

- English, Telugu, Hindi
- Romanized Telugu and Hindi
- Notes, ideas, decisions, project updates
- Tasks and explicit multi-item checklists
- Reminders and calendar proposals
- Several mixed task/reminder constructions
- Questions grounded in retrieved saved notes

### Not proven or intentionally excluded

- Perfect behavior for spontaneous noisy speech
- Universal accent or ASR robustness
- Email/message drafting through Core v4
- Coding-prompt generation through Core v4
- Reliable journal/meeting classification simply because those enum values exist
- Background model download after termination
- Knowledge of private notes without retrieval
- Consumer-scale latency, memory, thermal, and battery benchmarks

## 13. How to improve the model responsibly

Do not retrain after every individual failure. First collect a frozen, human-authored acceptance set containing audio, transcription, expected structure, and language metadata.

Recommended sequence:

1. Gather real English, Telugu, Hindi, and Romanized speech from multiple speakers.
2. Separate speech-recognition failures from model-routing failures.
3. Add missing query and checklist challenge cases.
4. Cluster repeated failures.
5. Fix general deterministic errors in code when appropriate.
6. Retrain only when enough genuinely new language examples justify it.
7. Re-run locked validation, test, challenge, and physical-device gates.
8. Never train on private notes or audio without explicit opt-in.

## 14. Reproducing the model integration

Application source:

```text
https://github.com/vashisht7/NoteEchoes
```

Model source:

```text
https://huggingface.co/Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit
```

A new developer or Codex task should:

1. Clone the Git repository.
2. Read this book and `NOTECHOES_APP_ARCHITECTURE_BOOK.md`.
3. Keep the immutable model revision and manifest checks.
4. Build with the same bundle/App Group identity when updating an existing phone.
5. Download the model from AI Model Settings.
6. Confirm the app reports `Ready` before multilingual acceptance testing.

## 15. Final perspective

The important achievement is not “a perfect 1.5B model.” It is a practical sub-1 GB local intelligence stack with a strict schema, multilingual specialization, safe deterministic boundaries, immutable distribution, and a real Flutter/iOS integration.

Its greatest strength is focus. Its greatest remaining risk is the gap between synthetic text evaluation and real human speech. The next major quality improvement should come from evidence collected from real usage—not from another blind training run.

