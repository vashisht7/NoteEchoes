# NoteEchoes — Current Handoff Guide

Last updated: 2026-08-17
Release: `v2.9.1` plus unreleased fixes on `main` through commit `399c585`

## What is working now

- iOS voice-note recording records the entire message to a temporary M4A file before transcription. This replaced the old live speech-session approach that could cut off long recordings.
- The app supports English, Telugu, Hindi, and automatic language selection for voice notes.
- A downloadable **Whisper Base Multilingual** model provides local/offline Telugu, Hindi, and English transcription.
- Without the downloaded Whisper model, the app falls back to Apple's speech recognition service; Whisper is the supported path for dependable offline Telugu.
- The iPhone Action Button / Shortcut transcription path uses the same native speech service and the selected app language.
- Notes created from voice and Action Button input are persisted and appear at the top of the home feed.
- The application uses a black, production-style theme. The selected accent colour is shared across the app.
- Existing PDF/text note, table-editor, local storage, and AI feature code remains in place.
- Notes now use SQLite with transactional migration from legacy preferences and rolling recovery backups.
- Qwen and Whisper availability is verified from their physical files on launch/resume; incomplete downloads are reported as needing repair.
- Multilingual E5 Small is an optional 123 MB, SHA-256-verified ONNX download for 384-dimensional semantic embeddings across 94 languages. It powers related-note suggestions and topic sections without uploading notes.
- Semantic vectors, relationships, topic clusters, membership confidence, and user confirmations/dismissals live in schema-v2 tables in `notechoes_ai.sqlite`.
- The Topics screen presents conservative on-device clusters; Qwen optionally assigns grounded names and summaries after E5 forms the clusters.
- Core notes, keyword search, checklists, tables, and Apple speech remain available without optional model downloads. Model-dependent features explain the required download before opening.
- The note editor supports swipe-back, inline cursor-positioned checklists, Return-to-add table rows, and an explicit add-column control.
- Conversation mode uses installed Apple Premium/Enhanced voices when available, synchronizes highlighted sentences from native speech callbacks, and stops speech on every route exit.
- Reduce Motion, Dynamic Type, VoiceOver labels/actions, and compact-iPhone layouts are supported.
- PDF attachments on iPhone now use Apple's native PDFKit reader rather than the third-party Flutter renderer. They open in a dedicated matte-black reader with pinch zoom, selectable clean text, per-page Markdown copying, accessible loading/error states, and a separate optional document-chat action. Back returns to the note; the note remains one step above the home page.
- Attachment references are stored relative to Documents and legacy absolute iOS-container paths are repaired automatically. PDF notes show a rendered first-page cover on the home card and inside the editor. The reader can switch to a clean selectable Markdown view, copy all extracted text, and use on-device Vision OCR for scanned pages.
- The note editor has a stable-width Done action. Done persists the note first, returns directly to the home page, and lets AI indexing continue in the background so the top bar does not twitch or delay navigation.

## Known installation limitation — must not be described as a permanent install

The current app installed from Xcode has been reported not to keep running after the iPhone is disconnected. Treat this as an unresolved distribution/signing issue, not as confirmed daily-use installation behavior.

On 2026-08-17, commit `f22f6fe` was compiled as a signed **Release** build, installed directly with Apple device services, and launched without a resident Flutter/Xcode debugger. The active development provisioning profile expires on **2026-08-21 at 05:45 UTC**. Cable disconnection should not terminate this detached Release installation, but it will need to be rebuilt/reinstalled after the temporary profile expires unless the app moves to TestFlight/App Store distribution.

- An Xcode Run session is a development/debug deployment. Disconnecting can terminate the debugger-launched process; the user should then try launching NoteEchoes directly from the iPhone Home Screen.
- Do **not** promise that a development-signed build will remain usable indefinitely. Its provisioning profile is temporary and can expire or become invalid.
- Before declaring this fixed, physically verify this exact sequence: install; stop Xcode; unplug the cable; force-close NoteEchoes; launch it from the iPhone Home Screen; create and save a note; restart the phone; launch again; confirm the note remains.
- For dependable testing away from the Mac, distribute through TestFlight using a paid Apple Developer account. For permanent public use, use an App Store release. A locally shared IPA is not a general-install solution unless every test device is included in a valid provisioning profile.
- Never replace the user's existing daily-data app/container merely to test this. Back up notes first and use a separate test bundle identifier when testing installation persistence.

## User setup for offline Telugu

1. Install and open the app.
2. Go to **Settings → Voice Notes → Offline Models**.
3. Download **Whisper Base Multilingual** (about 147 MB; requires an internet connection only for the download).
4. In **Settings → Voice Notes**, select **Telugu**. Select **Automatic** for mixed-language use, or English/Hindi when you want a fixed language.
5. Use the in-app microphone or the configured Action Button shortcut. Transcription happens locally after the model has downloaded.

English is also supported by the same multilingual model. It is not Telugu-only.

## App size

- Debug app build verified on device: approximately **235 MB**.
- Downloaded Whisper Base Multilingual model: approximately **147 MB**.
- Expected combined footprint: approximately **382 MB**, below the 1 GB target. Release/App Store size can differ.

## Important implementation files

| File | Purpose |
| --- | --- |
| `lib/widgets/siri_action_overlay.dart` | In-app microphone UI. Uses the `record` package to capture a complete M4A, then calls native transcription. Do not reintroduce a second live microphone engine while this recorder runs. |
| `ios/Runner/OfflineSpeechService.swift` | Native Flutter channel `noteechoes/offline_speech`. Downloads/loads WhisperKit Base multilingual and transcribes audio. Falls back to Apple Speech when Whisper is not installed. |
| `ios/Runner/TranscribeAudioNoteIntent.swift` | Action Button/Shortcut audio-intent path. Delegates transcription to `OfflineSpeechService`. |
| `ios/Runner/SceneDelegate.swift` | Registers native model, speech-output, PDF, Action Button, and recovery channels for UIScene launches. |
| `lib/services/note_storage_service.dart` | SQLite note store, preference migration, and rolling JSON recovery copies. |
| `lib/ai/infrastructure/model_availability_service.dart` | Physical Qwen/Whisper installation verification and synchronized feature availability. |
| `lib/ai/infrastructure/e5_embedding_service.dart` | Resumable E5 download, SHA-256 verification, SentencePiece tokenization, ONNX inference, mean pooling, and normalized embeddings. |
| `lib/ai/infrastructure/semantic_knowledge_service.dart` | Incremental indexing, calibrated similarity links, clustering, Qwen topic enrichment, and review decisions. |
| `lib/screens/topics_screen.dart` | Accessible Topics interface with note drill-down and confirm/dismiss controls. |
| `lib/screens/pdf_reader_screen.dart` | Full-page local PDF reader, page navigation, zoom/text selection, missing-file handling, and optional Ask PDF action. |
| `lib/services/attachment_path_service.dart` | Stable attachment references and recovery from stale iOS app-container paths. |
| `lib/widgets/pdf_cover_thumbnail.dart` | Cached-in-widget first-page PDF rendering used by home and editor attachment cards. |
| `lib/theme/app_preferences.dart` | Persisted app accent and voice language (`en`, `te`, `hi`, `auto`). |
| `lib/theme/app_theme.dart` | Black theme derived from the persisted accent. |
| `lib/screens/settings_screen.dart` | User-facing appearance and voice language settings. |
| `lib/ai/presentation/ai_model_settings_page.dart` | Offline Whisper download/manage UI. |
| `lib/services/note_service.dart` | Note creation/persistence; new items must remain newest-first in the home view. |

## Native dependency details

- Whisper engine: `WhisperKit` from `https://github.com/argmaxinc/argmax-oss-swift`.
- It is recorded in both Xcode Swift Package `Package.resolved` files and linked in `ios/Runner.xcodeproj/project.pbxproj`.
- Dart recording package: `record: ^7.1.1` in `pubspec.yaml`.
- After changing Flutter dependencies, run `flutter pub get` and then `cd ios && pod install` before building in Xcode.

## Build and run on iPhone

1. Open `ios/Runner.xcworkspace` in Xcode (not `Runner.xcodeproj`).
2. Select the **Runner** scheme and a connected iPhone.
3. Confirm the Signing team is selected for `com.vashisht.noteechoes`.
4. Press **Cmd + R**.
5. On first run, grant microphone and speech permissions.

Verification completed for v2.9.1:

- Full Flutter test suite: 26 tests passed.
- Flutter analyzer: no new errors; 27 existing warnings/information notices remain.
- Signed Release iPhone build and deep signature verification: passed.
- Installed and launched on the connected iPhone: passed.

Verification completed for the unreleased `399c585` PDF/save fixes:

- Full Flutter test suite: 27 tests passed.
- Analyzer on all modified Dart files: no issues.
- Native iOS Release compilation with code signing disabled: passed.
- A persistent disconnected-phone installation has **not** passed and remains required before the next release/IPA is claimed ready.
- Signed detached Release installation on the connected iPhone: passed; development profile expiration is 2026-08-21 05:45 UTC.

## Guardrails for future changes

- Preserve the full-file M4A recording → one transcription flow. The old restart/watchdog live-recognition design caused the reported cutoff issue.
- Never run Flutter physical integration tests against a daily-data installation using `com.vashisht.notechoes`; use an isolated test bundle/device because test deployment can replace the app container.
- Do not remove the SQLite recovery paths or acknowledge an Action Button queue item before the note commit succeeds.
- Keep the Whisper model downloadable, not bundled: this keeps the initial app reasonable in size and makes the model optional.
- Do not claim fully offline Telugu until the Whisper download has completed successfully.
- Preserve the black surface palette and use `Theme.of(context).colorScheme.primary` for accents instead of hard-coded neon blue/purple.
- `WhisperKit` currently produces Swift Sendable warnings under the present Xcode configuration, but the signed device build succeeds. Address them if Swift 6 strict-concurrency becomes enabled.
- Do not report “installed for daily use” merely because the app launches while attached to Xcode. The unplugged/restart persistence checklist above is a release gate.

## Repository

- Main repository: https://github.com/vashisht7/NoteEchoes
- Current release: https://github.com/vashisht7/NoteEchoes/releases/tag/v2.9.1
