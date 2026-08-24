# NoteEchoes Core v4 — iOS Release Handoff

Last updated: 2026-08-23

## Objective

Publish the verified NoteEchoes Core v4 MLX 4-bit model, update the Flutter/iOS application to download and validate that exact model without unsafe generic fallbacks, test the production path, and install the application on the connected iPhone.

## Immutable model facts

- Published repository: `Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit`
- Public URL: `https://huggingface.co/Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit`
- Immutable production revision: `ab5704d40dc4096e7460fb10443e99fc891b7196`
- Source folder: `/Users/vashishtdevasani/Downloads/noteechoes-qwen25-core-v4-mlx-4bit`
- Total folder size: 880,107,402 bytes (about 839 MiB)
- Main weights: `model.safetensors`, 868,628,547 bytes
- Main weights SHA-256: `4454aaa0b1cbddd255fb515c1172962672dab76778ba7469a9bf538ffca2c526`
- Required production behavior: exact fine-tuned model plus Core v4 adapter and deterministic guardrails
- Supported product scope: all English actions; Telugu/Hindi core notes, tasks, reminders, checklists, queries, and related actions; Telugu/Hindi email and prompt generation are not required

## Progress log

### 2026-08-23

- Confirmed the final local MLX model folder and all eight model/tokenizer files.
- Confirmed the connected iPhone is visible to Flutter as `Vashisht (2)`, device ID `00008150-000E29323642401C`, running iOS 26.6.
- Confirmed the application worktree already contains uncommitted Core v4 integration work. These changes are being preserved and extended rather than replaced.
- Confirmed the intended Hugging Face repository ID already appears in the native MLX service, but the repository is not published yet.
- Started auditing download, integrity, settings UI, native MLX loading, signing, and physical-device installation paths.
- Created the public Hugging Face repository `Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit` with Apache-2.0 metadata.
- Expanded the local model card and added `noteechoes-manifest.json` with exact sizes and SHA-256 values for all seven runtime files.
- Published all nine release files (model/tokenizer files, card, and integrity manifest) to Hugging Face.
- Verified the remote `model.safetensors` is 869 MB and has SHA-256 `4454aaa0b1cbddd255fb515c1172962672dab76778ba7469a9bf538ffca2c526`, exactly matching the local release file.
- Published the corrected integrity manifest and pinned the iOS loader to immutable signed commit `ab5704d40dc4096e7460fb10443e99fc891b7196`; the app does not follow mutable `main`.
- Removed native generic-model fallbacks from the production loader.
- Changed the iOS loader to use the exact NoteEchoes repository, support a pinned revision, require 2 GB free space during installation, exclude the model from device backup, verify every runtime file, and write a verification marker.
- Added model download cancellation/retry behavior, deterministic structured generation, exact model settings labels, repair messaging, and the correct 839 MiB download size.
- Successfully compiled and signed the modified iOS application for the connected physical iPhone. The final standalone release is preserved at `/Users/vashishtdevasani/Downloads/NoteEchoes-Core-v4-iOS-Release/Runner.app` (about 102 MiB on disk).
- Focused Core v4 adapter and prompt tests passed. The final rerun completed all 17 current tests with zero failures.
- The full Flutter suite reached 71 passing tests, then an existing accessibility/storage test process stalled and had to be stopped. No Core v4 test failed. Static analysis reports 41 existing project warnings/info items; no new Dart compilation error was introduced.
- Diagnosed the original device-build signing failure as cloud-storage extended attributes on generated frameworks. Building through a temporary non-cloud directory resolves it without moving source code.
- Hugging Face browser upload completed without creating or storing an API token. No secret is embedded in the repository, app, or handoff.
- Verified the signed application with Apple's code-signing tool.
- Installed `com.vashisht.notechoes` successfully on the paired iPhone 17 Pro Max. The first physical-device package was a debug build, which iOS correctly refused to launch standalone without Flutter tooling.
- Rebuilt the signed iOS app after pinning revision `ab5704d40dc4096e7460fb10443e99fc891b7196`. Apple code-sign verification passed.
- Replaced the debug package with a signed 107.1 MB release build and launched it successfully. Device inventory confirms NoteEchoes version `2.9.1`, build `5`, bundle `com.vashisht.notechoes`.
- Reproduced and diagnosed a device-only download crash: swift-transformers used completion-handler transfers with a background `URLSession`, which iOS rejects with `NSGenericException`. Changed the Hugging Face transport to its supported foreground session, retained immutable revision and full SHA verification, and changed the UI to tell users to keep NoteEchoes open during the one-time download.
- Rebuilt, signed, reinstalled, and launched the corrected release. The 839 MiB model downloaded on the physical iPhone, passed integrity verification, loaded into MLX, and displayed `Ready` in the app.
- Ran a temporary English reminder capture on the phone. The app classified it with reminder/event categories; the temporary note was then deleted, leaving the user's existing note intact.
- Preserved the final signed standalone release at `/Users/vashishtdevasani/Downloads/NoteEchoes-Core-v4-iOS-Release/Runner.app`, restored Flutter's global build directory to `build`, and removed the 2.2 GB generated temporary build directory.
- Fixed the natural spoken-checklist path after a product reproduction using “first task ... second ...”. Added a conservative grounded parser for explicit English, Telugu, Hindi, and Romanized checklist/enumeration speech; it creates only items present in the transcript and does not invent steps.
- Changed Action Button / Shortcut ingestion to use `NoteService.createFromVoiceTranscription`, so it now receives the same ready-model loading, Core v4 prompt, adapter, guardrails, and spoken-checklist safety net as the in-app microphone.
- Refreshes installed-model availability before voice inference, so a cold-launched app does not depend on a stale in-memory Ready flag.
- Clarified the Core v4 prompt to preserve independently spoken first/second/third checklist items in order.
- Added focused parser and NoteService regression tests. All 32 selected prompt, adapter, parser, service, and widget tests passed. Static analysis still reports the repository's existing 41 warning/info findings and no new compile error.
- Built a signed 107.1 MB iOS Release application using the documented non-cloud build workaround, installed it on connected device `00008150-000E29323642401C`, and launched bundle `com.vashisht.notechoes` successfully.
- Preserved this checklist-fix release at `/Users/vashishtdevasani/Downloads/NoteEchoes-Checklist-Release-2026-08-23/Runner.app`.
- Changed generated voice checklist notes to persist ordered checklist content blocks and open as a pure minimal checklist. The raw transcript remains stored for retrieval/recovery but is no longer repeated above the visible rows. Each row remains editable and toggles between incomplete and checked/struck-through states.
- Added `NOTECHOES_DART_MODEL_API.md` documenting the local MLX calling contract, immutable configuration, and natural Dart task/reminder/calendar examples. The local model is correctly described as an on-device provider rather than a web endpoint.
- The updated minimal-checklist suite passed 33 focused tests. Built, signed, installed, and launched the updated iOS Release on the connected phone. Preserved it at `/Users/vashishtdevasani/Downloads/NoteEchoes-Minimal-Checklist-Release-2026-08-23/Runner.app`.
- Polished checklist rows with a larger animated circular control, subtle row surface, and a clear overflow menu containing `Remove item` instead of an ambiguous close icon.
- Checklist completion now persists immediately, updates durable content blocks, and re-indexes `☑`/`☐` state. The voice assistant answers completed/pending counts from live note state before generic model retrieval.
- Added a product-side concise-title guarantee: model titles are limited to a meaningful 2–6 words and the app enforces a maximum of six words/48 characters.
- Connected explicit future-dated reminder captures to Apple Reminders. The native bridge now passes the correct millisecond alarm field and requests Reminders-only permission; vague or past reminders remain unscheduled.
- Added checklist-state and concise-title regression tests. The focused release suite now passes 34/34 tests.
- Bumped the application to `2.9.2 (6)`, produced a signed 106.4 MB iOS Release, verified its signature, and installed it in place over bundle `com.vashisht.notechoes` on the connected iPhone without uninstalling or clearing its data container. The preserved standalone build is `/Users/vashishtdevasani/Downloads/NoteEchoes-2.9.2-Core-v4-Release-2026-08-23/Runner.app`.
- Fixed the observed reminder-as-note failure with `SpokenReminderParser`, a deterministic fallback for explicit future times including “tomorrow at 9 AM” and short “in 2 minutes” tests. Successful captures now create an Apple Reminder plus a time-sensitive NoteEchoes Lock Screen notification and show a `Reminder scheduled` badge in the note card.
- Added notification authorization to the native reminder bridge and an Apple-style Settings row that opens the app's system settings for Lock Screen reminder control.
- Replaced the checklist overflow menu with one compact remove-circle control so deleting an item no longer opens a full-width menu tile.
- Added `VoiceCaptureValidator` to in-app recording, Action Button ingestion, pending queues, and the central NoteService boundary. Silence, filler-only speech, punctuation, and no-speech placeholders no longer create empty voice notes.
- The reminder/silence/checklist/model focused suite passes 39/39 tests. Built and signature-verified NoteEchoes `2.9.3 (7)` as a 106.5 MB release and installed it in place without uninstalling. Preserved release: `/Users/vashishtdevasani/Downloads/NoteEchoes-2.9.3-Reminder-Release-2026-08-23/Runner.app`.
- Added interactive notification actions through `ReminderNotificationCoordinator`: long press exposes `Done` and `Remind in 10 Minutes`; Done completes the Apple Reminder and clears the alert, while snooze moves its alarm and reschedules the NoteEchoes notification.
- Added the signed `NoteEchoesLiveActivity` WidgetKit extension and Dart/native bridge. Long-pressing any home note now offers `Add to Lock Screen`; checklists show pending rows and completion progress, edits synchronize, deleting removes the activity, and the Lock Screen close button ends it.
- Elevated home notes into rounded 18-point tiles with increased spacing, soft depth shadows, and a cleaner rounded long-press action sheet. Removed a visually redundant action-menu treatment.
- Bumped to `2.9.4 (8)`. The final app and embedded extension both compile and pass strict code-sign verification. iOS initially rejected an intermediate extension with an empty inherited build number; explicit extension version metadata fixed it, and the corrected package installed and launched successfully in place without clearing user data. Final signed build: `/Users/vashishtdevasani/Downloads/NoteEchoes-2.9.4-Lock-Screen-Final-2026-08-23/Runner.app`.

## Verified performance

- The raw MLX 4-bit model produced valid schema, mode, kind, action kinds, query behavior, and no-think behavior on 168/168 adversarial challenge rows. It missed only one metadata label: a Romanized Telugu project update was labeled `te` instead of `te-roman`, giving raw language accuracy 167/168 (99.4%).
- The exact product stack shipped in the app—model plus Core v4 adapter and deterministic guardrails—passed 168/168 challenge rows, including 26 English, 55 Hindi, 21 Romanized Hindi, 42 Telugu, and 24 Romanized Telugu rows.
- The recorded full release gate is 1,292/1,292: locked release 47/47, validation 534/534, test 543/543, and adversarial challenge 168/168.
- This is not an apples-to-apples benchmark against the older Qwen3 model because the older model was not evaluated on this same locked Core v4 suite. The defensible comparison is: the older release was observed to work well in English but fail Telugu/Hindi product behavior; Core v4 has explicit Hindi/Telugu/Romanized coverage, a fixed schema contract, deterministic app guardrails, and a perfect recorded product-stack release gate.

## Remaining work

- Run human-authored voice acceptance tests in English, Telugu, Hindi, and Romanized speech. The automated release suites and physical download/load path are complete, but real microphone/ASR conditions still need product acceptance testing.
- Commit and push the local app changes only if the repository owner explicitly wants these existing dirty-worktree changes published to GitHub.

## Blockers and user actions

- None. The final release app and verified model are installed on the paired phone.

## Safety notes

- Never place a Hugging Face access token in the application or this handoff file.
- Never upload user notes, private datasets, Kaggle credentials, or other secrets.
- Do not remove or overwrite unrelated existing worktree changes.
- The app worktree remains intentionally dirty because it contained user changes before this work. No Git commit or push was made.

## Documentation index

- `NOTECHOES_MODEL_DATASET_AND_PREPARATION.md` — complete dataset history, Core v4 contract, Kaggle training configuration, artifact preparation, evaluation interpretation, and model distribution record.
- `NOTECHOES_SPEAKING_GUIDE.md` — supported speech patterns and examples for notes, ideas, decisions, updates, tasks, checklists, reminders, events, combined actions, memory queries, and negative commands.
- `NOTECHOES_SENIOR_ENGINEERING_ASSESSMENT.md` — candid six-year-experience product/engineering review, readiness scorecard, risks, and private-beta priorities.
