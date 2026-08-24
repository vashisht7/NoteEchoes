# The NoteEchoes Application Architecture Book

**A readable guide to the product, its Flutter/Dart architecture, its native Apple integrations, and the files that matter**

Last verified: 2026-08-24  
Current installed release: 2.9.7 (11)  
Bundle ID: `com.vashisht.notechoes`  
App Group: `group.com.vashisht.notechoes`  

---

## 1. What NoteEchoes is

NoteEchoes is a private-first memory and action application. A person can speak or type naturally, and the app turns that input into a useful local object:

- A note or thought
- An idea or decision
- A project update
- A checklist with independently completable rows
- An Apple Reminder and Lock Screen alert
- A calendar-event proposal
- A saved-memory question
- An imported document with searchable passages

The design principle is simple: capture should feel effortless, but side effects must be explicit and durable.

## 2. The architecture at a glance

```text
┌─────────────────────────────────────────────────────────────┐
│ Flutter presentation                                        │
│ Home • Editor • Voice • Topics • Settings • Document chat   │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Dart product services                                       │
│ NoteService • voice validation • checklist/reminder parsing │
│ title cleanup • Lock Screen bridge • storage                │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Dart AI/domain layer                                        │
│ prompts • Core v4 guardrails • adapter • retrieval • topics │
└───────────────────────────┬─────────────────────────────────┘
                            │ Flutter MethodChannels
┌───────────────────────────▼─────────────────────────────────┐
│ Native iOS services                                         │
│ MLX • EventKit • notifications • ActivityKit • speech • PDF │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│ Durable local state                                         │
│ SQLite • Documents backup • App Group • Drift AI database   │
└─────────────────────────────────────────────────────────────┘
```

Flutter owns the product experience. Swift is used where Apple frameworks or MLX require native code.

## 3. The main application entry

### `lib/main.dart`

This starts Flutter, initializes preferences and storage, configures the theme, and presents `HomeScreen`.

### `lib/theme/app_theme.dart`

This defines the global dark Apple-inspired visual system:

- App colors and typography
- Rounded cards
- Inputs and selection colors
- High-contrast rounded floating confirmation banners

### `lib/theme/app_colors.dart`

This is the shared color vocabulary: matte black surfaces, graphite elevations, crimson branding, secondary text, and semantic green/blue/orange/purple accents.

## 4. The durable note model

### `lib/models/note_model.dart`

`NoteModel` is the primary saved object. Important fields include:

```text
noteId
title
contentType
summarySnippet
textContent
createdAt
tags
isPinned
checklist
contentBlocks
mediaAssets
accentColor
```

Structured content is not flattened away:

- `NoteBlockData.text` stores editor text.
- `NoteBlockData.table` stores cell rows.
- `NoteBlockData.checklist` stores item identity, text, and completion.
- `MediaAsset` stores image, PDF, or audio references.

Checklist item IDs are important. They allow a tap in the editor, home card, or Lock Screen to update the same logical item.

## 5. Storage and data safety

### `lib/services/note_storage_service.dart`

User notes are stored in SQLite under Application Support. The service provides:

- Schema creation
- Legacy SharedPreferences migration
- Transactional upsert/delete/save
- Local Documents recovery backup
- App Group recovery backup through Swift
- Recovery when the database is missing or empty

### `lib/services/note_service.dart`

`NoteService` is the central in-memory product store and `ChangeNotifier`. It:

- Loads notes once
- Creates notes from voice transcription
- Adds, updates, deletes, and pins notes
- Toggles checklist items
- Applies checklist actions made on the Lock Screen
- Writes changes through `NoteStorageService`
- Updates full-text and semantic indexes
- Updates an active Live Activity

### Why updates preserve notes

The application database lives in Application Support, and its safety copy lives in Documents/App Group storage. Installing a new build over the same bundle ID retains the iOS data container. Uninstalling the app removes that container.

The downloaded MLX model is intentionally treated as reproducible. It is excluded from backup because it can be downloaded and verified again.

## 6. Voice capture paths

NoteEchoes has several ways to receive speech.

### In-app voice overlay

Key files:

- `lib/widgets/siri_action_overlay.dart`
- `lib/screens/voice_assistant_screen.dart`
- `lib/services/voice_assistant_service.dart`
- `lib/services/voice_capture_validator.dart`

The overlay records or receives transcription, rejects silence/filler-only captures, then passes meaningful speech to `NoteService.createFromVoiceTranscription`.

### Action Button and Apple Shortcuts

Key files:

- `ios/Runner/SaveDictatedNoteIntent.swift`
- `ios/Runner/TranscribeAudioNoteIntent.swift`
- `ios/Runner/NotechoesShortcuts.swift`
- `ios/Runner/PendingVoiceNoteStore.swift`
- `lib/services/action_button_note_ingestion_service.dart`

The native Shortcut can capture while Flutter is not in the foreground. It places data in a durable App Group queue. Flutter imports pending notes at startup, resume, and lightweight polling intervals.

All capture paths eventually use the same NoteService logic. This prevents the Action Button from bypassing model loading, checklist parsing, reminders, or storage.

### Empty-capture protection

`lib/services/voice_capture_validator.dart` rejects:

- Silence markers
- Empty punctuation
- Filler-only speech
- Known “no speech” placeholders

This boundary exists both near the UI and inside NoteService so a future caller cannot accidentally save an empty voice memo.

## 7. How a spoken note becomes structured

The normal flow is:

```text
transcribed speech
  → VoiceCaptureValidator
  → AiCategorizationEngine lightweight baseline
  → ModelAvailabilityService refresh
  → QwenLlamaProvider Core v4 analysis when Ready
  → CoreActionV4Guardrails
  → CoreActionV4Adapter
  → SpokenChecklistParser safety net
  → SpokenReminderParser date safety net
  → VoiceNoteTitleService concise title
  → NoteModel
  → SQLite + indexes + UI
```

### Important files

| File | Role |
| --- | --- |
| `lib/services/ai_categorization_engine.dart` | Lightweight offline baseline |
| `lib/ai/infrastructure/qwen_llama_provider.dart` | Local Core v4 provider |
| `lib/ai/infrastructure/prompt_repository.dart` | Structured prompts |
| `lib/ai/domain/core_action_v4_guardrails.dart` | Safety corrections |
| `lib/ai/domain/core_action_v4_adapter.dart` | JSON-to-domain conversion |
| `lib/services/spoken_checklist_parser.dart` | Explicit enumeration safety net |
| `lib/services/spoken_reminder_parser.dart` | Explicit future-time safety net |
| `lib/services/voice_note_title_service.dart` | Enforces a short useful heading |

The raw transcript is retained for memory/recovery. A checklist editor does not repeat the entire transcript above the rows.

## 8. Checklists

### Creation

Core v4 can return action items. The deterministic spoken parser also recognizes explicit natural enumerations such as “first … second …” in English, Telugu, Hindi, and Romanized speech.

The parser is conservative: it requires multiple explicit items and does not convert ordinary prose into a checklist.

### UI and persistence

Checklist rows appear as true interactive items, not decorative bullet text. Completion updates:

- `NoteModel.checklist`
- Matching checklist content blocks
- Searchable `☑`/`☐` text
- SQLite
- Semantic and keyword indexes
- Home-card progress
- Active Live Activity

### Important files

- `lib/services/note_service.dart`
- `lib/screens/note_detail_screen.dart`
- `lib/widgets/keep_text_note_card.dart`
- `lib/services/checklist_status_service.dart`

`ChecklistStatusService` answers questions such as “How many are left?” from the current saved state instead of asking the model to guess.

## 9. Three different Apple reminder surfaces

These systems must not be confused.

### 9.1 Apple Reminder

An Apple Reminder is an EventKit object visible in Apple's Reminders app.

Files:

- `lib/platform/ios/apple_calendar_bridge.dart`
- `ios/Runner/SceneDelegate.swift`

For explicit future reminders, Dart requests permission and Swift creates the `EKReminder` with an alarm. The app marks the note with reminder tags only after successful native creation.

### 9.2 Local notification

A local notification is a scheduled Lock Screen/banner alert.

File:

- `ios/Runner/ReminderNotificationCoordinator.swift`

Long-press actions include:

- **Done** — completes the matching Apple Reminder and clears the alert.
- **Remind in 10 Minutes** — moves the reminder alarm and schedules a replacement notification.

This is the right system for “alert me at a future time.”

### 9.3 Live Activity

A Live Activity is a user-pinned, continuously visible ActivityKit surface. It is not a future alarm and iOS controls its lifetime.

Files:

- `lib/services/lock_screen_activity_service.dart`
- `ios/Runner/LockScreenActivityCoordinator.swift`
- `ios/Runner/NoteEchoesActivityAttributes.swift`
- `ios/NoteEchoesLiveActivity/NoteEchoesLiveActivityWidget.swift`

The home-card long-press menu offers **Add to Lock Screen**. Plain notes show as much text as Apple's height permits. Checklists show up to four interactive rows and progress.

### Immediate Lock Screen checklist updates

`ToggleLockScreenChecklistIntent` is declared in `NoteEchoesActivityAttributes.swift`, which belongs to both Runner and the WidgetKit target. This is intentional. Apple runs `LiveActivityIntent` in the containing application process, allowing it to find the ActivityKit object and update the green checked row immediately without opening the app visually.

The intent also writes a durable action to the shared App Group. When Flutter becomes active, `NoteService.applyLockScreenChecklistActions()` applies the exact state to SQLite and the home UI.

Do not move this intent into an extension-only file. That previously caused the app state to change while the Live Activity remained visually stale until NoteEchoes opened.

## 10. The home screen

### `lib/screens/home_screen.dart`

The home screen is the main coordinator. It:

- Displays notes in a chronological/pinned feed
- Hosts search and navigation
- Opens the note editor and voice assistant
- Imports pending Action Button notes
- Reconciles recovery backups
- Reconciles Lock Screen checklist actions on resume
- Refreshes model availability and semantic indexes
- Shows the long-press note action sheet

### `lib/widgets/keep_text_note_card.dart`

This renders the polished note tile, including checklist progress and reminder state.

Bottom confirmations use the global rounded SnackBar theme so dark text is never rendered against a dark surface.

## 11. The editor

### `lib/screens/note_detail_screen.dart`

This is the full block editor. It supports:

- Text blocks
- Structured checklist blocks
- Editable inline tables
- Media and PDF attachments
- Formatting tools
- Markdown/math display
- Saving and reopening without flattening structure

Supporting widgets include:

- `lib/widgets/apple_notes_toolbar.dart`
- `lib/widgets/apple_text_format_sheet.dart`
- `lib/widgets/inline_note_table.dart`
- `lib/widgets/math_markdown_viewer.dart`
- `lib/widgets/apple_drawing_canvas.dart`

## 12. Topics and knowledge connections

### `lib/screens/topics_screen.dart`

Topics opens as an Apple-style collection dashboard. Stable collections include:

- Reminders
- Checklists
- Plans & Events
- Projects
- Ideas
- Meetings
- Documents
- Notes

Tapping a collection card or graph node opens a rounded draggable sheet containing every connected note.

### `lib/ai/infrastructure/semantic_knowledge_service.dart`

This service creates embeddings, note relationships, semantic clusters, and stable product collections.

The stable collections are necessary because short action notes can be semantically similar enough to collapse into one large “task” cluster. Product collections keep different object types discoverable while learned relationships remain available.

### `lib/ai/infrastructure/e5_embedding_service.dart`

This manages the separate multilingual embedding model used for related notes and topic clustering.

### `lib/ai/infrastructure/knowledge_service.dart`

This owns the Drift AI database and keyword/index operations.

## 13. Model installation and inference

### `ios/Runner/MLXTextGenerationService.swift`

This native service:

- Downloads the pinned Hugging Face revision
- Requires sufficient free space
- Verifies every runtime file
- Excludes the reproducible model from backup
- Loads the model with MLX
- Performs structured generation
- Reports progress and errors to Flutter

### `lib/ai/presentation/ai_model_settings_page.dart`

This is the user-facing model management UI: download, progress, Ready/repair state, cancellation, and diagnostics.

### `lib/ai/infrastructure/model_availability_service.dart`

This turns native status into Dart states:

```text
checking | missing | ready | needsRepair | unavailable
```

### `lib/ai/infrastructure/model_integrity_service.dart`

This supports file verification and repair decisions.

The production model is approximately 839 MiB and is not embedded inside the 107 MB app package.

## 14. Search, retrieval, and document intelligence

Important files:

- `lib/ai/infrastructure/ai_database.dart`
- `lib/ai/infrastructure/fts_retrieval_provider.dart`
- `lib/ai/infrastructure/hybrid_retrieval_service.dart`
- `lib/ai/application/ask_notebook_use_case.dart`
- `lib/ai/application/ask_document_use_case.dart`
- `lib/ai/application/ingest_document_use_case.dart`
- `lib/ai/infrastructure/pdfrx_document_processor.dart`
- `ios/Runner/PDFVisionExtractionService.swift`

The retrieval layer combines keyword and semantic evidence. Answers about saved notes or documents should be grounded in retrieved passages and citations, not model memory.

## 15. Dart-to-Swift channels

| Channel | Purpose |
| --- | --- |
| `noteechoes/mlx_text_generation` | Model status, download, load, generation |
| `noteechoes/offline_speech` | Whisper model/status/transcription |
| `noteechoes/calendar` | Reminders and calendar integration |
| `noteechoes/lock_screen_activity` | Show, update, remove, and reconcile Live Activities |
| `noteechoes/note_backup` | App Group recovery backup |
| `noteechoes/speech_output` | Native speech synthesis |
| `noteechoes/pdf_vision` | Native PDF text/vision extraction |
| `com.vashisht.notechoes/action_button` | Action Button and pending capture coordination |

`ios/Runner/SceneDelegate.swift` registers most of these bridges. `ios/Runner/AppDelegate.swift` configures notifications, shortcuts, and application-level native services.

## 16. Screen map

| Screen | File | Purpose |
| --- | --- | --- |
| Home | `lib/screens/home_screen.dart` | Feed, capture, search, long-press actions |
| Editor | `lib/screens/note_detail_screen.dart` | Structured note editing |
| Voice assistant | `lib/screens/voice_assistant_screen.dart` | Listening, thinking, speaking, memory answers |
| Topics | `lib/screens/topics_screen.dart` | Collections and semantic connections |
| Settings | `lib/screens/settings_screen.dart` | Product preferences and model entry |
| AI model settings | `lib/ai/presentation/ai_model_settings_page.dart` | Download and model health |
| PDF reader | `lib/screens/pdf_reader_screen.dart` | Reading and extracted content |
| Document chat | `lib/ai/presentation/document_chat_page.dart` | Grounded document Q&A |

## 17. Building on another Mac or Codex task

Source repository:

```text
https://github.com/vashisht7/NoteEchoes
```

Basic setup:

```bash
git clone https://github.com/vashisht7/NoteEchoes.git
cd NoteEchoes
flutter pub get
open ios/Runner.xcworkspace
```

In Xcode:

1. Select the Apple development team.
2. Keep iOS 17 or newer.
3. Keep the App Group `group.com.vashisht.notechoes` for same-team updates.
4. Build the workspace, not only the project file.
5. Install over the existing app when preserving data.
6. Open AI Model Settings and download/verify Core v4.

The model is downloaded separately from:

```text
https://huggingface.co/Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit
```

Git contains code and documentation. Hugging Face contains public model artifacts. Neither location contains the user's private notes.

## 18. Signing, expiry, and long-term use

The currently installed build is signed with Apple Development / Personal Team `8UKWK3U3Y2`.

For release 2.9.7:

- Main application profile expiration: `2026-08-29T04:19:56Z`
- Live Activity extension profile expiration: `2026-08-31T03:40:34Z`
- Apple Development certificate expiration: `2027-08-07T18:02:13Z`

The earliest embedded profile controls the practical lifetime, so the current app must be refreshed by August 29.

### What happens after expiration

Leaving the app installed does not make a free Personal Team profile permanent. After the profile expires, iOS can refuse to launch the development-signed app. Local data does not change that code-signing rule.

### Reinstalling after ten days

Yes, the same source can be rebuilt with a new profile and installed again. To retain data:

- Use the same Apple team.
- Use the same bundle ID: `com.vashisht.notechoes`.
- Keep the same App Group.
- Install over the existing application.
- Do not uninstall first.

Reinstalling “the same old Runner.app” after its embedded profile expires is not enough; it still contains the expired profile. It must be rebuilt or re-signed with a newly issued profile.

For a consumer product and long-term installation, use a paid Apple Developer membership and distribute through TestFlight or the App Store while preserving bundle identity.

## 19. Release and test status

Current physical-device build:

```text
/Users/vashishtdevasani/Downloads/NoteEchoes-2.9.7-Live-Checklist-Fix-2026-08-24/Runner.app
```

Authoritative GitHub IPA release:

```text
https://github.com/vashisht7/NoteEchoes/releases/tag/v2.9.7
```

Direct download:

```text
https://github.com/vashisht7/NoteEchoes/releases/download/v2.9.7/NoteEchoes-v2.9.7-build11.ipa
```

The verified IPA is 31,214,474 bytes with SHA-256:

```text
610b47dbfc2bf17d4012fb4ff65ead402f6fe3d455fb45e533af0a40560960cd
```

The repository root also contains an older `NoteEchoes.ipa`. It predates the
current release and is not the authoritative install package. Release assets
are versioned, checksummed, and do not inflate every Git source clone.

### Downloading on another Mac

Browser method:

1. Open the v2.9.7 GitHub Release.
2. Expand **Assets** if necessary.
3. Download `NoteEchoes-v2.9.7-build11.ipa`.

GitHub CLI method:

```bash
gh release download v2.9.7 \
  --repo vashisht7/NoteEchoes \
  --pattern 'NoteEchoes-v2.9.7-build11.ipa'
```

To install the packaged app with Apple's command-line device tooling:

```bash
unzip NoteEchoes-v2.9.7-build11.ipa -d NoteEchoes-v2.9.7
xcrun devicectl device install app \
  --device YOUR_DEVICE_UDID \
  NoteEchoes-v2.9.7/Payload/Runner.app
```

This succeeds only on a device authorized by the embedded provisioning
profile and only before that profile expires. To refresh an expired build,
clone the repository and produce a newly signed build; downloading the same
expired IPA again cannot renew its signature.

Current Git commit at the time of this book's preparation:

```text
b3cbad9 — fix: update live checklist immediately
```

The recent release path has:

- 44 focused product tests passing
- Signed Runner and Live Activity extension
- Strict code-sign verification
- In-place installation on the connected iPhone
- Preserved data-container UUID

The final Live Activity acceptance tap must still be tested by a person on the physical Lock Screen using a newly created activity.

## 20. Known product boundaries

- Personal Team builds require periodic re-signing.
- A Live Activity is not a permanent notification.
- A scheduled notification is not the same as an Apple Reminder.
- Semantic grouping is helpful, not infallible.
- The 839 MiB model download currently expects the app to remain open.
- Real speech quality depends on transcription quality as well as Core v4.
- Moving to another bundle ID or developer team creates a separate iOS data container.
- Cross-device note migration needs an explicit encrypted export/import or cloud-sync feature.

## 21. The first files a new engineer should read

Read these in order:

1. `NOTECHOES_MODEL_BOOK.md`
2. `NOTECHOES_APP_ARCHITECTURE_BOOK.md`
3. `lib/models/note_model.dart`
4. `lib/services/note_service.dart`
5. `lib/services/note_storage_service.dart`
6. `lib/ai/infrastructure/qwen_llama_provider.dart`
7. `lib/ai/domain/core_action_v4_guardrails.dart`
8. `lib/screens/home_screen.dart`
9. `lib/screens/note_detail_screen.dart`
10. `ios/Runner/SceneDelegate.swift`
11. `ios/Runner/MLXTextGenerationService.swift`
12. `ios/Runner/NoteEchoesActivityAttributes.swift`

## 22. Final perspective

NoteEchoes is no longer only a note-taking interface with a model attached. It is a layered local system: capture, validation, structured interpretation, safe native actions, durable storage, retrieval, and glanceable Apple surfaces.

The architecture is strongest when each layer keeps its responsibility:

- The model interprets.
- Guardrails validate.
- Dart decides and stores.
- Swift talks to Apple frameworks.
- The UI shows real saved state.
- Private user data stays local unless the user explicitly chooses a future sync/export mechanism.
