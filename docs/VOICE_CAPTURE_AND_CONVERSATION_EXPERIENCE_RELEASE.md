# Voice Capture and Conversation Experience Release

## Release identity

- App version: 2.9.9 (build 13)
- Scope: English-first voice capture, reminder visibility, typed note actions, conversation responsiveness, iPhone/AirPods speech, and generated-report presentation.
- Installation rule: install in place with `com.vashisht.notechoes`; never uninstall the existing app because that would remove local data.

## Resolved issues

### Correct local time

All note timestamps now convert persisted UTC values to the iPhone's local timezone before determining Today/Yesterday and formatting the clock. New voice notes capture their timestamp at the beginning of the save operation rather than after analysis finishes.

### Fast and durable Save

- A useful live transcript no longer triggers a redundant full-file Whisper pass.
- The note is committed to SQLite before optional model enrichment.
- Recovery copies still run, but no longer block the Save interaction.
- Qwen title/action enrichment runs in the background with bounded timeouts.
- Reminder scheduling starts immediately in the background and updates the saved note through pending, scheduled, or failed states.

SQLite remains the authoritative durable write. Background recovery mirroring and enrichment do not weaken the primary save.

### Visible typed notes and actions

Every text note has one compact bottom-right type icon:

- alarm: reminder;
- checklist: checklist/task list;
- envelope: email draft;
- chat bubble: message draft;
- lines: ordinary note.

Reminder cards show their local due time and scheduling state. Message and email icons open the native iOS composer with a grounded draft. iOS still requires the user to choose the recipient when it cannot be safely extracted and to tap Send; the app never silently contacts someone.

### Conversation cannot wait indefinitely

- Full-audio transcription is bounded to 10 seconds.
- hybrid retrieval is bounded to 8 seconds;
- conversational generation is bounded to 12 seconds;
- a deterministic grounded local report replaces a timed-out generation rather than leaving the screen spinning.

### iPhone and AirPods spoken output

Each response now resets any old recorder/synthesizer state, rebuilds `AVSpeechSynthesizer`, reactivates the current playback route, and reports the active output route and volume. Playback respects the current route, including AirPods, instead of forcing the iPhone speaker. Flutter waits for real speech callbacks and reports a failed start; Listen remains available for retry.

### Modern report surface

The generated report no longer renders each sentence as an animated card. It uses an editorial reading surface with a compact header, private/on-device source count, restrained section labels, normal paragraphs and bullets, and a single Listen/Save/Copy action bar. It still opens at three-quarter height and expands to full screen.

## Verification

- 106 Flutter tests passed.
- Focused static analysis of all changed Dart files reported no issues.
- Signed iOS release builds passed twice; the final bundle is version 2.9.9 (build 13), 107.7 MB, and its signature verified.
- The build was installed in place and launched on the connected iPhone. The installation retained the same application database UUID, confirming that existing app data was not removed.

## Device acceptance checks

1. Save a short spoken note; it should return in roughly the time needed to stop live recognition and commit SQLite, not wait for model inference.
2. Confirm a note captured from a UTC/native source displays the iPhone's local time.
3. Say “Remind me in one minute to check app.” Watch the card move from Scheduling to a local due time and receive the alert.
4. Connect AirPods, request a conversation summary, and confirm the response is heard in AirPods. Disconnect them and repeat through the iPhone speaker.
5. Capture message and email drafts and tap their bottom-right icons. Confirm the native composer opens with the draft but does not send without confirmation.
