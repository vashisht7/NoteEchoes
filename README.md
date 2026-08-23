# 🛡️ NoteEchoes

**NoteEchoes** is a next-generation, private-first AI note-taking and voice intelligence application for **iOS and macOS**. It combines on-device neural transcription, mathematical LaTeX previewing, Apple Notes-style block editing with interactive inline tables, and headless Apple Shortcuts integration for instant voice capture.

---

## 📖 Architecture & Developer Documentation
For the complete technical blueprint, directory index mapping every Dart/Swift file to its functionality, and agent handoff details, see:
👉 **[ARCHITECTURE_AND_AGENT_HANDOFF.md](ARCHITECTURE_AND_AGENT_HANDOFF.md)**

For the device-download strategy, free product scope, monetization options, and
custom-model roadmap, see **[future_plans.md](future_plans.md)**.

For the production NoteEchoes Core v4 integration, start with:

- **[NOTECHOES_CORE_V4_IOS_HANDOFF.md](NOTECHOES_CORE_V4_IOS_HANDOFF.md)** — exact model revision, download flow, verification, and release handoff
- **[NOTECHOES_DART_MODEL_API.md](NOTECHOES_DART_MODEL_API.md)** — Dart-facing request/response contract and natural-language examples
- **[NOTECHOES_MODEL_AND_CHECKLIST_RECOVERY_PLAN.md](NOTECHOES_MODEL_AND_CHECKLIST_RECOVERY_PLAN.md)** — checklist behavior, application wiring, tests, and remaining work
- **[NOTECHOES_MODEL_DATASET_AND_PREPARATION.md](NOTECHOES_MODEL_DATASET_AND_PREPARATION.md)** — training data, evaluation, model preparation, and artifact inventory
- **[NOTECHOES_SPEAKING_GUIDE.md](NOTECHOES_SPEAKING_GUIDE.md)** — practical English, Hindi, and Telugu voice examples

---

## 🌟 Key Features

```
+---------------------------------------------------------------------------------------------------------------+
|                                            NOTECHOES CAPABILITIES                                             |
+---------------------------------------------------------------------------------------------------------------+
| 1. 🎙️ Action Button & Apple Shortcuts Voice Capture                                                            |
|    • Multilingual "Record Audio" -> "Transcribe Audio" -> "Save Dictated Note" Shortcut                    |
|    • Durable App Group queue shared by the Shortcut and the main app                                          |
|    • Automatic first-frame ingestion into unified chronological feed on home screen                           |
|                                                                                                               |
| 2. 📝 Full-Screen Apple Notes-Style Editor                                                                    |
|    • Floating accessory toolbar docked directly above the iOS soft keyboard                                  |
|    • Aa typography modal sheet (Title, Heading, Subheading, Monospaced, Bold, Italic, Bullet, Numbered, Quote) |
|    • Block-editor architecture: cursor-level inline interactive tables with dynamic row/column additions       |
|    • Math & Markdown live preview toggle ($$ \int e^{-x^2} dx $$, tables, syntax highlighting)                |
|    • Native sketch markup canvas with Apple Pencil & finger drawing support                                   |
|                                                                                                               |
| 3. 📱 Unified Chronological Feed                                                                              |
|    • Newest notes (voice memos, text, checklists, rich docs) always appear on the top                         |
|    • Pinned notes prioritized at the top-left with glowing indicators                                         |
|    • Keep-style dual-column masonry grid with voice memo wave badges and formatted timestamps                 |
|                                                                                                               |
| 4. 🧠 Local On-Device AI Architecture (Phases 1-12)                                                            |
|    • NoteEchoes Core v4 (Qwen2.5-1.5B MLX 4-bit); pinned download on first use (~839 MiB)                     |
|    • Multilingual transcription supplied by Apple's Transcribe Audio Shortcut action                          |
|    • SQLite / Drift database with persistent background AI job queue & FTS5 full-text search                  |
|    • Grounded document Q&A and cross-notebook semantic synthesis                                              |
|    • Apple Intelligence Writing Tools, EventKit Calendar, CoreSpotlight, and Journaling bridges              |
+---------------------------------------------------------------------------------------------------------------+
```

---

## 🛠️ Build & Run from Source

### Prerequisites
- Flutter SDK (3.24+ / 3.29+)
- Current Xcode with the Apple Metal Toolchain installed
- iOS 17+

### Setup Commands
```bash
# 1. Clone repository
git clone https://github.com/vashisht7/NoteEchoes.git
cd NoteEchoes

# 2. Install dependencies
flutter pub get

# 3. Open the workspace (not Runner.xcodeproj)
open ios/Runner.xcworkspace

# 4. Run on macOS
flutter run -d macos

# 5. Run on Connected iOS Device
flutter run -d ios
```

In Xcode, select your Apple team and connected iPhone. Keep the App Group
`group.com.vashisht.notechoes` enabled. If Xcode asks, trust the official MLX
build plugin. The AI model is downloaded from the model settings page and is
not stored in the application bundle. The app downloads the immutable revision
`ab5704d40dc4096e7460fb10443e99fc891b7196` from
[`Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit`](https://huggingface.co/Vashisht7/noteechoes-qwen25-core-v4-mlx-4bit)
and verifies the expected files before enabling local inference.

The unsigned iPhone release build measured approximately 77 MB on August 14,
2026. Final App Store download and installed sizes can differ because of signing,
compression, and device thinning.

---

## 📄 License
MIT License. Built for next-generation spatial computing, tactile mobile UX, and private on-device intelligence.
