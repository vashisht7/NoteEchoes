# Voice Reminder and Conversation Reliability

## Release

- App version: 2.9.8 (build 12)
- Product position: English-first; Hindi and Telugu remain assisted/best-effort paths.
- Data migration: unchanged. The iPhone build must be installed in place with the existing bundle identifier. Do not uninstall the previous app.

## Resolved behavior

### Spoken reminders

- Natural relative phrases such as “Remind me in one minute to check app,” “in a minute,” numeric durations, and English compound values through 69 are parsed locally.
- The time phrase is removed from the reminder title.
- Reminder success now requires both Apple Reminders permission and notification permission.
- The native reminder and its local time-sensitive notification are both created. A native scheduling error is returned to Flutter instead of being silently ignored.
- The capture result visibly distinguishes “iPhone reminder scheduled” from a permission/scheduling failure.

### Conversation reports

- Semantic-only retrieval candidates are hydrated from the authoritative local note store before a response is created. Placeholder titles such as “Note” no longer replace actual note content.
- Text, summary fallback, checklist items, and structured content blocks are available to the grounded report.
- Broad requests produce a deterministic report with Summary, Key points, and Sources sections. The action model is not misused as an unrestricted summarizer.
- The completed report opens as a three-quarter-height sheet and can expand to full screen.
- Replay and Copy are always visible. Audio failures show an actionable message instead of appearing to play silently.

### Spoken response reliability

- The completed report is rendered before spoken playback begins.
- Flutter waits for a real native start acknowledgement rather than assuming success after 200 milliseconds.
- Native speech callbacks drive the highlighting. A watchdog reports a failed speaker start and keeps Replay available.
- The native route uses `.playAndRecord` with `.voicePrompt`, default speaker output, and AirPods-compatible Bluetooth options.

### Non-speech filtering

- Bracketed, asterisked, and plain tokens for gasps, breathing, coughs, sighs, sniffing, laughter, silence, and background noise are removed.
- Meaningful words around those tokens are preserved. A sound-only transcript is rejected and does not create a note.

## Verification

- Full Flutter suite: 104 tests passed.
- Focused static analysis: no issues in the changed Dart files.
- Signed iOS release build: passed twice; version 2.9.8 (build 12), 107.7 MB application bundle, signature verified.
- Device deployment: installed in place on the connected iPhone with bundle identifier `com.vashisht.notechoes`; existing data was not removed. Automatic launch was blocked only because the iPhone was locked.
- Focused coverage includes the exact one-minute reminder phrase, compound relative durations, non-speech filtering, grounded report structure, compact-iPhone layout, visible Replay, SQLite migration, and PDF navigation.
- Future builds must continue to install in place; never uninstall first.

## Manual device checks

1. Open NoteEchoes and allow Reminders and Notifications if prompted.
2. Say: “Remind me in one minute to check app.” Confirm the green “iPhone reminder scheduled” result, then lock the phone and wait for the alert.
3. In Conversation, say: “Summarize my notes.” Confirm that the report opens automatically, shows content under Summary and Key points, lists actual note titles under Sources, and speaks aloud.
4. Tap Replay. If audio cannot start, use the visible message to check volume/output route and try Replay again.
5. Dictate “Gasp. Remind me to call Ravi, breathing.” Confirm the saved text does not display the sound labels.

## Design reference

The simplified report follows proven patterns from Apple Notes and Otter: the result is primary, source/transcript context remains visible, replay is easy to find, and actions are limited to the small set needed after a report is ready.
