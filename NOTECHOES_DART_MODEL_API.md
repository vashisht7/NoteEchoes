# NoteEchoes Local Model — Dart Configuration and Calling Contract

Last updated: 2026-08-23

## Important distinction

The current NoteEchoes model is not a web API and has no HTTP endpoint. It is a private 4-bit MLX model downloaded from Hugging Face and invoked locally through the Dart `QwenLlamaProvider` and the iOS method channel `noteechoes/mlx_text_generation`.

The application should send natural speech. Do not convert the user's words into artificial command syntax before inference.

## Production configuration

```dart
const modelRepository =
    'Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit';
const modelRevision =
    'ab5704d40dc4096e7460fb10443e99fc891b7196';
const modelVersion = 'noteechoes-qwen25-core-v4-mlx-4bit';
const promptVersion = 'v4.0-checklist-grounding';
const schemaVersion = 4;
```

The immutable revision and manifest hashes must be verified by the native downloader. Do not use mutable `main` for a production release.

## One local interpretation call

```dart
import 'package:notechoes_app/ai/infrastructure/model_availability_service.dart';
import 'package:notechoes_app/ai/infrastructure/qwen_llama_provider.dart';

Future<void> interpret(String naturalSpeech) async {
  await ModelAvailabilityService.instance.refresh();
  if (!ModelAvailabilityService.instance.qwen.isReady) {
    throw StateError('Download NoteEchoes Core v4 in AI Model Settings.');
  }

  final model = QwenLlamaProvider.instance;
  if (!model.isLoaded) await model.load();

  final result = await model.generateNoteAnalysis(
    naturalSpeech,
    noteId: 'capture-${DateTime.now().microsecondsSinceEpoch}',
    noteCreatedAt: DateTime.now(),
  );

  // Tasks/checklist rows
  for (final item in result.actionItems) {
    print(item.task);
  }

  // Proposals: show confirmation before writing to iOS.
  for (final reminder in result.reminders) {
    print(reminder.title);
  }
  for (final event in result.events) {
    print(event.title);
  }
}
```

For normal product capture, use the higher-level method so the note and checklist are persisted:

```dart
final note = await NoteService().createFromVoiceTranscription(
  'First task, check whether the model works. '
  'Second task, check whether the app works.',
);

// note.checklist contains two interactive rows.
```

## Natural task calls

### Multiple tasks

```dart
await NoteService().createFromVoiceTranscription(
  'First task, check whether the model works. '
  'Second task, check whether the app works. '
  'Third task, test it on the phone.',
);
```

### Explicit checklist

```dart
await NoteService().createFromVoiceTranscription(
  'Create a checklist with these items: buy milk, call Ravi, '
  'and charge the laptop.',
);
```

### One task

```dart
await NoteService().createFromVoiceTranscription(
  'Add submit the tax form to my task list.',
);
```

Do not ask the model to invent steps. If the user says only “plan my release,” save one grounded task or ask for the desired items.

## Natural reminder call

```dart
final result = await QwenLlamaProvider.instance.generateNoteAnalysis(
  'Remind me tomorrow at 9 AM to send the proposal to Maya.',
  noteId: 'reminder-${DateTime.now().microsecondsSinceEpoch}',
  noteCreatedAt: DateTime.now(),
);

final proposal = result.reminders.single;
// Present proposal.title and proposal.triggerDate for confirmation.
// Only after confirmation should CalendarProvider.createReminder be called.
```

Natural examples:

```text
Remind me tomorrow at 9 AM to call Ravi.
రేపు ఉదయం 9 గంటలకు రవికి కాల్ చేయాలని గుర్తు చెయ్యి.
कल सुबह 9 बजे रवि को कॉल करने की याद दिलाना।
Repu morning 9 ki Ravi ki call cheyyalani gurthu cheyyi.
```

If the user says “remind me later,” the product must ask for a specific time rather than silently scheduling it.

## Natural calendar call

```dart
final result = await QwenLlamaProvider.instance.generateNoteAnalysis(
  'Schedule a design review with Maya next Monday at 3 PM.',
  noteId: 'event-${DateTime.now().microsecondsSinceEpoch}',
  noteCreatedAt: DateTime.now(),
);

final proposal = result.events.single;
// Show confirmation, then call CalendarProvider.createEvent(proposal).
```

## Core v4 wire response

The raw model returns JSON in this shape:

```json
{
  "v": 4,
  "language": "en",
  "mode": "capture",
  "kind": "task_list",
  "title": "Model and app checks",
  "summary": "Check the model and application",
  "actions": [
    {
      "kind": "task",
      "text": "Model and app checks",
      "items": [
        "check whether the model works",
        "check whether the app works"
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

Valid action kinds are:

```text
task
reminder
calendar_event
```

Never parse these fields directly in UI widgets. Pass the response through `CoreActionV4Guardrails` and `CoreActionV4Adapter`, then render domain objects.

## Minimal checklist UI behavior

For a note with `note.checklist.isNotEmpty`:

- Render the title once.
- Render only the checklist rows; do not repeat the raw transcript.
- Use an empty circle for incomplete and a filled check for complete.
- Tapping the circle toggles `isCompleted` and persists it through `NoteService.toggleCheckItem`.
- Completed text uses a strikethrough and quieter color.
- Keep the raw transcript stored internally for retrieval and recovery.

The home card already follows this rule. The checklist editor now also opens generated voice checklists as pure interactive rows rather than showing the transcript followed by the same rows.
