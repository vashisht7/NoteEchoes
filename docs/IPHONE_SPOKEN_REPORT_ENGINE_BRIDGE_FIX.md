# iPhone Spoken Report Engine Bridge Fix

## Release

- App version: `2.10.1+15`
- Platform: iPhone
- Scope: conversation reports, Read Aloud, replay, AirPods, and iPhone speaker

## User-visible result

NoteEchoes now waits for the generated conversation report and sends its readable text to the native iPhone speech engine. The playback control changes to the playing state only after iOS reports that the first spoken segment actually started. If iOS cannot start speech, the app shows a real error instead of claiming that spoken output is available.

The audio session uses spoken playback. It follows an active AirPods route, uses the iPhone speaker when no external route is active, works with the silent switch enabled, and temporarily lowers other audio while the report is spoken.

## Root cause

The Flutter speech channel was previously attached from the scene lifecycle. The app uses Flutter's implicit-engine lifecycle, so the scene callback could run without the correct engine messenger. Dart then received `MissingPluginException` and showed “Spoken output is available when running on iPhone,” even though no request reached `AVSpeechSynthesizer`.

## Correction

- Registered the speech output bridge directly from `AppDelegate.didInitializeImplicitFlutterEngine` on the active Flutter engine messenger.
- Consolidated ownership in a single `SpeechOutputChannelService` and removed the obsolete scene-owned speech implementation.
- Configured `AVAudioSession` for output-only spoken playback with AirPods support and speaker fallback.
- Held the Flutter `speak` response until `AVSpeechSynthesizerDelegate.didStart` confirmed real playback.
- Added a native start timeout so silent failure is visible and recoverable.
- Kept segment callbacks for pause, resume, replay, completion, and progress tracking.
- Removed optimistic playback-state updates from the Flutter UI.

## Physical-device verification

The signed release was installed in place on the connected iPhone without removing the app or its data. The database installation UUID remained:

`7B579E2E-5573-452B-BED8-7EADDCF99B56`

The device-only smoke test reached the native `didStart` callback and reported:

- Started: `true`
- Route: `Vashisht’s AirPods Pro`
- Output volume: `0.95`
- Voice: `Rishi (Enhanced)`
- Voice identifier: `com.apple.voice.enhanced.en-IN.Rishi`

This verifies actual iOS speech-engine startup rather than only a Flutter UI state.

## Validation

- Full Flutter test suite: 115 tests passed.
- Focused static analysis of the changed Dart service: no issues.
- Signed iPhone release: code signature valid.
- Installed build: `2.10.1+15`.

## Expected behavior

After a conversation report finishes generating, NoteEchoes reads it automatically. Replay starts from the beginning, pause stops native speech, and resume continues from the tracked segment. When AirPods are connected, iOS routes speech to them. Disconnect AirPods or select iPhone in Control Center to hear it from the phone speaker.
