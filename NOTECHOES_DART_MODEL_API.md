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

  // Lower-level callers receive structured reminder/event proposals.
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
// Low-level callers may present a confirmation and then call
// CalendarProvider.createReminder. The normal NoteService voice-capture path
// writes an explicit, future-dated "remind me" command to Apple Reminders.
```

Natural examples:

```text
Remind me tomorrow at 9 AM to call Ravi.
రేపు ఉదయం 9 గంటలకు రవికి కాల్ చేయాలని గుర్తు చెయ్యి.
कल सुबह 9 बजे रवि को कॉल करने की याद दिलाना।
Repu morning 9 ki Ravi ki call cheyyalani gurthu cheyyi.
```

If the user says “remind me later,” the product must ask for a specific time rather than silently scheduling it.

For the normal application flow, call `NoteService.createFromVoiceTranscription`.
When the model returns an explicit reminder with a valid future time, NoteEchoes
requests Reminders access and creates an `EKReminder` with an alarm. Apple then
shows the reminder on the Lock Screen according to the user's Reminders
notification settings. Vague or past times are not scheduled.

The release also uses `SpokenReminderParser` as a deterministic safety net. A
clear timed command is therefore scheduled even if the compact model returns a
plain note. NoteEchoes creates both the Apple Reminder and a time-sensitive
local notification. The note card receives the `reminder-scheduled` tag and
visibly shows “Reminder scheduled.” Examples supported by the safety net:

```text
Remind me tomorrow at 9 AM to call Ravi.
Remind me in 2 minutes to check the app.
```

A future reminder uses a standard Lock Screen notification, not Live Activity.
Live Activities are for continuously updating ongoing events and are not a
reliable replacement for a scheduled alarm.

Reminder notifications use the native `NOTEECHOES_REMINDER` category. Long
pressing the notification exposes `Done` and `Remind in 10 Minutes`. Done marks
the corresponding `EKReminder` complete and clears the delivered notification;
snooze updates the reminder alarm and schedules a replacement notification.

## User-pinned Lock Screen notes

The home-card long-press menu has a separate `Add to Lock Screen` action. This
uses ActivityKit, because a Live Activity is the Apple-supported rounded,
updating Lock Screen surface:

```dart
await LockScreenActivityService.instance.show(note);
```

For checklists it displays up to four rows with real interactive checkboxes.
A Lock Screen tap updates the Live Activity immediately and is also stored in
the shared App Group action queue. When NoteEchoes becomes active,
`NoteService.applyLockScreenChecklistActions()` applies the exact completed
state to the SQLite note, content blocks, home-card progress badge, search
index, and current Live Activity. This makes the Lock Screen and home screen
converge without placing the notes database inside the extension.

`NoteService.toggleCheckItem` continues to update the active surface when a
row is changed inside the app. Editing the note updates it; deleting the note
removes it. The Lock Screen has a full-size `Remove` capsule which ends the
Live Activity immediately. A pinned plain-text note sends its complete text
rather than only its summary; the extension reduces font size and increases
its line allowance for longer content, within Apple's Live Activity height.

iOS controls Live Activity lifetime and can end one after its system maximum.
NoteEchoes keeps it active until the user removes it within that Apple-managed
window, but the application cannot promise permanent or indefinite display.

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
- Persist the completion state immediately; do not wait for the editor to close.
- Re-index the updated `☑`/`☐` state so memory questions use the current list.
- Completed text uses a strikethrough and quieter color.
- Keep the raw transcript stored internally for retrieval and recovery.

The home card already follows this rule. The checklist editor now also opens generated voice checklists as pure interactive rows rather than showing the transcript followed by the same rows.

## Checklist progress memory

Checklist counts are a deterministic app API, not a generative-model guess:

```dart
final answer = ChecklistStatusService.answer(
  'How many tasks are done and pending?',
  NoteService().allNotes,
);

print(answer?.text);
// Release Checklist has 3 tasks: 1 completed and 2 pending.
```

The voice assistant invokes this before generic retrieval. It reads the latest
persisted `CheckListItem.isCompleted` values and responds in English, Telugu, or
Hindi. If the question contains a checklist title, that checklist is preferred;
otherwise the latest checklist is used.

## Voice-title guarantee

The model is asked for a meaningful 2–6 word title. The app then applies
`VoiceNoteTitleService.concise`, which removes conversational prefixes and
enforces six words and 48 characters. This prevents the entire transcription
from appearing as a heading even when the compact model echoes the input.

## Empty-capture guarantee

Every voice ingestion route calls `VoiceCaptureValidator` before creating a
note. Silence, punctuation, filler-only results, and transcription placeholders
such as “No speech detected” or “Voice memo” are acknowledged and discarded;
they never enter note storage.
