# NoteEchoes — System Architecture & Agent Handoff Guide

> **Current Repository Status**: Fully configured, build-verified for iOS/macOS, clean Flutter analyzer (0 errors), all latest voice note ingestion, home screen feed sorting, keyboard toolbar floating, and cursor-level inline tables committed to Git.

---

## 1. Executive Summary & Product Architecture

**NoteEchoes** is a next-generation, private-first notes and voice intelligence application built with **Flutter 3.x / Dart 3.x** and native **Swift 5** iOS/macOS platform layers. It combines the sleek tactile aesthetics of **Apple Notes & Apple Music** with on-device AI transcription, neural categorisation, math LaTeX previewing, and headless Apple Shortcuts integration.

### Core Technology Stack
- **Framework**: Flutter (Channel stable), Dart 3.7+
- **Platform Layer**: Swift 5, AppIntents, Speech framework (`SFSpeechRecognizer`), AVFoundation
- **Local Storage**: `shared_preferences`, SQLite / Drift (`ai_database.dart`), App Group shared containers
- **UI Architecture**: OLED Black (`#000000`), Liquid Droplet voice canvas, glassmorphic floating bars, Keep-style dual-column masonry grid, Apple Notes Aa formatting toolbar
- **Target Platforms**: iOS 16.0+ (with Action Button & App Shortcuts support), macOS 13.0+, Web / Android ready

---

## 2. Directory Map & File Directory Index

This section maps **every active file** in the codebase to its functionality.

```
lib/
├── main.dart                                    # App entry point, storage init, AI config bootstrap, theme setup
├── models/
│   ├── note_model.dart                          # NoteModel entity, NoteContentType (richMedia/textOnly), MediaAsset, CheckListItem
│   └── note_node.dart                           # Graph / semantic node representations
├── services/
│   ├── action_button_note_ingestion_service.dart# Drains iOS Action Button / Shortcuts queue into NoteService on launch & resume
│   ├── ai_categorization_engine.dart            # Heuristic + AI title generation, category extraction, checklist extraction
│   ├── note_service.dart                        # Central ChangeNotifier for notes state, search filtering, tag queries, persistence
│   ├── note_storage_service.dart                # Local JSON persistence using SharedPreferences & pending file notes queue
│   └── voice_assistant_service.dart             # Real-time microphone listening, speech-to-text, and conversational AI state
├── screens/
│   ├── home_screen.dart                         # Main unified feed with search, tag chips, masonry grid, and floating navigation bar
│   ├── note_detail_screen.dart                  # Full-screen Apple Notes-style editor with block model, inline tables & floating toolbar
│   ├── note_detail_sheet.dart                   # Legacy modal sheet editor (kept for backward compatibility / quick preview)
│   ├── settings_screen.dart                     # App settings, theme options, user profile, and AI model manager route
│   └── voice_assistant_screen.dart              # Immersive interactive voice AI canvas with liquid droplet visualizer
├── widgets/
│   ├── apple_drawing_canvas.dart                # Apple Pencil / finger drawing canvas with undo, stroke widths, and color palette
│   ├── apple_music_media_card.dart              # Rich media card for PDFs, images, and audio attachments with glossy artwork
│   ├── apple_notes_toolbar.dart                 # Accessory toolbar (Table, Aa, Checklist, Camera, Sketch, Math, Hide Keyboard)
│   ├── apple_text_format_sheet.dart             # Apple Notes style typography modal (Title, Heading, Bold, Italic, Lists, Quotes)
│   ├── auth_sign_in_sheet.dart                  # Apple ID and Google sign-in modal sheet
│   ├── expanding_search_bar.dart                # Fluid animated search header with instant query filtering
│   ├── floating_glass_nav_bar.dart              # Glassmorphic 5-button bottom navigation bar (Add, Search, Mic, AI, Settings)
│   ├── inline_note_table.dart                   # Interactive inline editable table with dynamic rows, columns, and header cells
│   ├── keep_text_note_card.dart                 # Google Keep-style dual-column card with voice memo badges and timestamps
│   ├── macos_window_header.dart                 # macOS-styled window traffic lights and branded emblem title
│   ├── math_markdown_viewer.dart                # Markdown renderer supporting LaTeX math expressions and code highlighting
│   ├── siri_action_overlay.dart                 # Glowing Siri aura overlay for Action Button recording and dictation
│   ├── voice_visualizer_painter.dart            # Multi-frequency audio waveform visualizer for real-time speech
│   └── voice/
│       ├── karaoke_lyrics_view.dart             # Real-time synchronized text streaming for live speech transcription
│       ├── liquid_droplet_painter.dart          # Organic metaball fluid physics for the voice assistant sphere
│       ├── nebula_liquid_painter.dart           # Ambient glowing background particle aura
│       └── orbital_notes_ring.dart              # Floating orbital cards surrounding the voice droplet
├── theme/
│   ├── app_colors.dart                          # OLED blacks, nebula cyans, droplet reds, apple yellows, glass borders
│   └── app_theme.dart                           # Flutter ThemeData definition (dark mode, custom typography)
├── utils/
│   └── date_formatter.dart                      # Smart timestamp formatter ("Today, 10:42 PM", "Yesterday", "Oct 14")
├── platform/ios/
│   ├── apple_calendar_bridge.dart               # EventKit bridge for exporting suggested reminders/events to iOS Calendar
│   ├── apple_intelligence_bridge.dart           # Apple Intelligence Writing Tools & Foundation Model integration
│   ├── apple_journaling_bridge.dart             # iOS 17.2+ Journaling Suggestions picker bridge
│   └── apple_spotlight_bridge.dart              # CoreSpotlight indexing bridge for native iOS system search
└── ai/                                          # Local On-Device AI Subsystem (Phases 1-12)
    ├── ai.dart                                  # Umbrella export file for AI modules
    ├── config/
    │   ├── ai_feature_flags.dart                # Runtime feature toggles (local LLM, Dolphin STT, PDF ingestion)
    │   ├── ai_runtime_config.dart               # Device RAM detection, NPU capabilities, thermal state
    │   └── model_manifest.dart                  # Catalog of downloadable on-device models (GGUF, Sherpa ONNX)
    ├── domain/
    │   ├── ai_models.dart                       # AI message types, model descriptors, download metadata
    │   ├── document_chunk.dart                  # PDF chunking and processing state representations
    │   ├── note_analysis.dart                   # Structured extraction (actions, people, places, events, tags)
    │   ├── source_citation.dart                 # Source attribution for grounded RAG answers
    │   ├── suggested_action.dart                # Calendar events / reminders extracted by LLM
    │   └── transcript.dart                      # Audio transcript results and timestamped segments
    ├── infrastructure/
    │   ├── ai_database.dart                     # Drift / SQLite database with tables for jobs, chunks, FTS5 index
    │   ├── ai_job_queue.dart                    # Persistent background job queue (transcription, analysis, indexing)
    │   ├── ai_telemetry_service.dart            # Performance metrics and inference latency logging
    │   ├── dolphin_sherpa_provider.dart         # Sherpa-ONNX Dolphin STT offline provider
    │   ├── fts_retrieval_provider.dart          # SQLite FTS5 full-text search and BM25 ranker
    │   ├── model_download_service.dart          # Resumable HTTP download service with Wi-Fi gating & .part files
    │   ├── model_integrity_service.dart         # SHA-256 checksum validator for downloaded AI models
    │   ├── pdfrx_document_processor.dart        # PDF text extraction and chunking processor
    │   ├── prompt_repository.dart               # Versioned system & user prompts for note analysis and Q&A
    │   └── qwen_llama_provider.dart             # Qwen 3.5 0.8B local LLM provider with categorization fallback
    ├── application/
    │   ├── analyze_note_use_case.dart           # Orchestrates note analysis, NER extraction, and FTS indexing
    │   ├── ask_document_use_case.dart           # Grounded Q&A against individual PDF documents
    │   ├── ask_notebook_use_case.dart           # Cross-note RAG Q&A across the user's entire notebook
    │   ├── create_meeting_summary_use_case.dart # Generates structured meeting summaries from transcripts
    │   ├── extract_actions_use_case.dart        # Converts note analysis into confirmed Apple Calendar events
    │   ├── ingest_document_use_case.dart        # Ingests, hashes, and indexes PDF files into Drift database
    │   ├── journal_review_use_case.dart         # Generates weekly/daily reflective journal summaries
    │   └── transcribe_note_use_case.dart        # Manages background audio transcription pipeline
    ├── presentation/
    │   ├── ai_model_settings_page.dart          # UI for downloading and managing local LLM and STT models
    │   ├── document_chat_page.dart              # Interactive conversational chat interface for PDFs
    │   ├── journal_review_page.dart             # Journal memory and weekly reflection UI
    │   ├── note_insights_view.dart              # Visual breakdown of extracted topics, people, and reminders
    │   └── suggested_actions_review.dart        # Action item review card with "Add to Calendar" button
    └── providers/
        ├── calendar_provider.dart               # Abstract interface for Calendar & Reminders
        ├── document_processor.dart              # Abstract interface for PDF extraction
        ├── retrieval_provider.dart              # Abstract interface for vector/FTS search
        ├── text_generation_provider.dart        # Abstract interface for local LLM inference
        └── transcription_provider.dart          # Abstract interface for audio STT providers

ios/Runner/
├── AppDelegate.swift                            # Standard Flutter AppDelegate
├── SceneDelegate.swift                          # MethodChannel handler for Action Button & URL scheme triggers
├── NotechoesShortcuts.swift                     # AppShortcutsProvider registering shortcuts in iOS Shortcuts app
├── PendingVoiceNoteStore.swift                  # Multi-tier thread-safe actor queue for pending voice recordings
├── SaveDictatedNoteIntent.swift                 # Headless AppIntent for text dictation Shortcut
├── TranscribeAudioNoteIntent.swift              # Headless AppIntent for audio transcription (chunked 1-hr audio)
├── Runner.entitlements                          # App Group entitlement (`group.com.vashisht.notechoes`)
└── Info.plist                                   # Speech recognition, microphone, and URL scheme declarations
```

---

## 3. Key Subsystems & How They Work

### 3.1. Headless Action Button & Shortcuts Pipeline

```
[ iPhone Action Button / Shortcuts ]
                  │
                  ▼
[ TranscribeAudioNoteIntent / SaveDictatedNoteIntent ]
                  │
                  ├─► Copies audio to local temp sandbox
                  ├─► Runs chunked SFSpeechRecognizer (supports 1-hr audio)
                  ▼
[ PendingVoiceNoteStore (Actor) ]
                  │
                  ├─► Tier 1: App Group Shared File Container
                  ├─► Tier 2: App Group Suite UserDefaults (`group.com.vashisht.notechoes`)
                  └─► Tier 3: Standard UserDefaults Fallback
                  │
                  ▼
[ iOS App Launch / Resume ]
                  │
                  ▼
[ ActionButtonNoteIngestionService ]
                  │ (MethodChannel: peekPendingActionButtonNote)
                  ▼
[ NoteService.addNote() ]
                  │ (notifyListeners)
                  ▼
[ HomeScreen (Unified Chronological Feed) ] -> Appears right at the top!
```

### 3.2. Full-Screen Note Editor Block Architecture

The note editor in [`lib/screens/note_detail_screen.dart`](file:///Users/vashishtdevasani/Desktop/Notechoes%20App/lib/screens/note_detail_screen.dart) uses a flexible **Block Editor**:
- Text is split into `_TextBlock` instances with individual `TextEditingController` and `FocusNode` objects.
- Tapping **Table** on the keyboard toolbar splits the active `_TextBlock` at the cursor position and inserts an [`InlineNoteTable`](file:///Users/vashishtdevasani/Desktop/Notechoes%20App/lib/widgets/inline_note_table.dart) between the text blocks.
- The `AppleNotesToolbar` is housed at the bottom of a `Column` wrapped in `Padding(bottom: viewInsets.bottom)`, which ensures it **stays permanently docked directly above the iOS soft keyboard**.

### 3.3. Chronological Feed Layout on Home Screen

In [`lib/screens/home_screen.dart`](file:///Users/vashishtdevasani/Desktop/Notechoes%20App/lib/screens/home_screen.dart):
- `_buildHybridGrid(notes)` renders all notes in a unified `SliverMasonryGrid.count`.
- Sorting is strictly: Pinned notes first, then chronological descending (`b.createdAt.compareTo(a.createdAt)`).
- Every new voice note or created note immediately populates at index 0 (top-left tile).

---

## 4. Xcode Installation & Running on Device

1. Open the workspace in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In Xcode:
   - Select the **Runner** target -> **Signing & Capabilities**.
   - Ensure your **Development Team** is selected.
   - Verify the **App Groups** capability shows `group.com.vashisht.notechoes`.
3. Build and Run:
   - Press **Cmd + R** to run on a physical iPhone or Simulator.

---

## 5. Information for Future Agents & Developers

When continuing work on this codebase:
- **Do not call MethodChannels before `runApp()`**: MethodChannels require an active `FlutterViewController` window attached after the first frame. Always use `WidgetsBinding.instance.addPostFrameCallback` or lifecycle listeners.
- **Maintain Multi-Tier Storage**: When extending App Intents or Shortcuts, always write to `PendingVoiceNoteStore.shared` so data synchronizes across process boundaries.
- **Block Editor State**: When adding new rich components to `note_detail_screen.dart` (e.g. image blocks, voice waveforms), follow the `_TextBlock` / `_TableBlock` block pattern.
- **AI Providers**: The local AI interfaces in `lib/ai/providers/` are decoupled via clean abstract interfaces (`TextGenerationProvider`, `TranscriptionProvider`, `DocumentProcessor`, `RetrievalProvider`).
