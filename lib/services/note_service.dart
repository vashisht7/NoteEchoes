import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import 'ai_categorization_engine.dart';
import 'spoken_checklist_parser.dart';
import 'voice_note_title_service.dart';
import 'voice_capture_validator.dart';
import 'spoken_reminder_parser.dart';
import 'note_tag_taxonomy.dart';
import 'lock_screen_activity_service.dart';
import 'note_storage_service.dart';
import '../ai/domain/note_analysis.dart';
import '../ai/infrastructure/action_model_router.dart';
import '../ai/infrastructure/knowledge_service.dart';
import '../ai/infrastructure/model_availability_service.dart';
import '../ai/infrastructure/multilingual_interpretation_service.dart';
import '../ai/infrastructure/qwen_llama_provider.dart';
import '../ai/infrastructure/semantic_knowledge_service.dart';
import '../platform/ios/apple_calendar_bridge.dart';
import '../ai/providers/calendar_provider.dart';
import '../theme/app_preferences.dart';

class NoteService extends ChangeNotifier {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;

  NoteService._internal();

  // Clean starting state: empty by default, loaded from local storage
  final List<NoteModel> _notes = [];
  String _searchQuery = '';
  String _selectedTag = 'All';
  bool _isSignedIn = false;
  String? _userEmail;
  String? _authProvider; // "apple" or "google"
  bool _isInitialized = false;
  bool _backgroundIndexingEnabled = true;
  Future<void> _lastIndexingTask = Future<void>.value();

  bool get isSignedIn => _isSignedIn;
  String? get userEmail => _userEmail;
  String? get authProvider => _authProvider;
  bool get isInitialized => _isInitialized;

  Future<void>? _storageInitFuture;
  Future<void> _writeTail = Future<void>.value();

  Future<void> initStorage() {
    _storageInitFuture ??= _initStorage();
    return _storageInitFuture!;
  }

  Future<void> _initStorage() async {
    final loaded = await NoteStorageService().loadNotes();
    final existingIds = _notes.map((n) => n.noteId).toSet();
    for (final note in loaded) {
      if (!existingIds.contains(note.noteId)) {
        final normalized = _normalizeTags(note);
        _notes.add(normalized);
        if (!listEquals(note.tags, normalized.tags)) {
          unawaited(_persistNote(normalized));
        }
      }
    }
    _isInitialized = true;
    for (final note in _notes) {
      try {
        await KnowledgeService.instance.indexNote(note);
      } catch (error) {
        debugPrint('Could not index note ${note.noteId}: $error');
      }
    }
    notifyListeners();
  }

  Future<void> reloadRecoveredNotes() async {
    final loaded = await NoteStorageService().loadNotes();
    final existingIds = _notes.map((note) => note.noteId).toSet();
    var changed = false;
    for (final note in loaded) {
      if (existingIds.add(note.noteId)) {
        final normalized = _normalizeTags(note);
        _notes.add(normalized);
        if (!listEquals(note.tags, normalized.tags)) {
          unawaited(_persistNote(normalized));
        }
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Applies checklist taps made directly on an iOS Live Activity. The native
  /// extension keeps these actions in the shared App Group until the app next
  /// becomes active, so a Lock Screen tap is never lost.
  Future<void> applyLockScreenChecklistActions() async {
    await initStorage();
    final actions = await LockScreenActivityService.instance
        .consumeChecklistActions();
    if (actions.isEmpty) return;

    final latestByItem = <String, Map<String, dynamic>>{};
    for (final action in actions) {
      final noteId = action['noteId'] as String? ?? '';
      final itemId = action['itemId'] as String? ?? '';
      if (noteId.isNotEmpty && itemId.isNotEmpty) {
        latestByItem['$noteId\u0000$itemId'] = action;
      }
    }

    final changedNotes = <NoteModel>[];
    for (final action in latestByItem.values) {
      final noteId = action['noteId'] as String;
      final itemId = action['itemId'] as String;
      final completed = action['completed'] as bool? ?? false;
      final noteIndex = _notes.indexWhere((note) => note.noteId == noteId);
      if (noteIndex == -1) continue;
      final note = _notes[noteIndex];
      final currentIndex = note.checklist.indexWhere(
        (item) => item.id == itemId,
      );
      if (currentIndex == -1 ||
          note.checklist[currentIndex].isCompleted == completed) {
        continue;
      }

      final checklist = note.checklist
          .map(
            (item) => CheckListItem(
              id: item.id,
              text: item.text,
              isCompleted: item.id == itemId ? completed : item.isCompleted,
            ),
          )
          .toList();
      final stateById = {
        for (final item in checklist) item.id: item.isCompleted,
      };
      final blocks = note.contentBlocks
          .map(
            (block) => block.type == NoteBlockType.checklist
                ? NoteBlockData.checklist(
                    checklistId: block.checklistId,
                    checklistText: block.checklistText,
                    checklistCompleted:
                        stateById[block.checklistId] ??
                        block.checklistCompleted,
                  )
                : block,
          )
          .toList();
      final searchable = blocks.isNotEmpty
          ? blocks
                .map((block) => block.searchableText)
                .where((text) => text.trim().isNotEmpty)
                .join('\n')
          : checklist
                .map((item) => '${item.isCompleted ? '☑' : '☐'} ${item.text}')
                .join('\n');
      final updated = note.copyWith(
        checklist: checklist,
        contentBlocks: blocks,
        textContent: searchable,
        summarySnippet: searchable,
      );
      _notes[noteIndex] = updated;
      changedNotes.removeWhere((value) => value.noteId == updated.noteId);
      changedNotes.add(updated);
    }

    if (changedNotes.isEmpty) return;
    notifyListeners();
    for (final note in changedNotes) {
      await _persistNote(note);
      _scheduleNoteIndexing(note);
      unawaited(LockScreenActivityService.instance.updateIfActive(note));
    }
  }

  Future<void> _persistNote(NoteModel note) {
    final write = _writeTail.then((_) => NoteStorageService().upsertNote(note));
    _writeTail = write.catchError((Object _) {});
    return write;
  }

  Future<void> _deletePersistedNote(String noteId) {
    final write = _writeTail.then(
      (_) => NoteStorageService().deleteNote(noteId),
    );
    _writeTail = write.catchError((Object _) {});
    return write;
  }

  void signIn({required String email, required String provider}) {
    _isSignedIn = true;
    _userEmail = email;
    _authProvider = provider;
    notifyListeners();
  }

  void signOut() {
    _isSignedIn = false;
    _userEmail = null;
    _authProvider = null;
    notifyListeners();
  }

  @visibleForTesting
  void clearNotesForTesting() {
    _notes.clear();
    _searchQuery = '';
    _selectedTag = 'All';
    _isInitialized = false;
    _storageInitFuture = null;
    _writeTail = Future<void>.value();
  }

  List<NoteModel> get notes {
    var filtered = _notes.where((note) {
      final matchesTag =
          _selectedTag == 'All' || note.tags.contains(_selectedTag);
      final matchesQuery =
          _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.summarySnippet.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          note.textContent.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.tags.any(
            (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      return matchesTag && matchesQuery;
    }).toList();

    // Pinned notes first, then chronological
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  List<NoteModel> get allNotes => List.unmodifiable(_notes);

  List<String> get allTags {
    final tagsSet = <String>{'All'};
    for (final note in _notes) {
      tagsSet.addAll(note.tags);
    }
    return tagsSet.toList();
  }

  String get searchQuery => _searchQuery;
  String get selectedTag => _selectedTag;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedTag(String tag) {
    _selectedTag = tag == 'All' ? tag : NoteTagTaxonomy.canonical(tag);
    notifyListeners();
  }

  Future<void> addNote(NoteModel note) async {
    await initStorage();
    note = _normalizeTags(note);
    _notes.removeWhere((n) => n.noteId == note.noteId);
    _notes.insert(0, note);
    notifyListeners();
    await _persistNote(note);
    _scheduleNoteIndexing(note);
  }

  /// Creates and saves a note directly from voice transcription or speech
  /// using the on-device AI categorization engine.
  Future<NoteModel> createFromVoiceTranscription(
    String spokenText, {
    String? noteId,
    DateTime? createdAt,
  }) async {
    final capturedAt = createdAt ?? DateTime.now();
    spokenText = VoiceCaptureValidator.sanitizeTranscript(spokenText);
    if (!VoiceCaptureValidator.hasMeaningfulSpeech(spokenText)) {
      throw const FormatException('No meaningful speech was captured.');
    }
    final normalizedText =
        MultilingualInterpretationService.normalizeTranscript(spokenText);
    final cleanNoteText =
        VoiceCaptureValidator.hasMeaningfulSpeech(normalizedText)
        ? normalizedText
        : spokenText.trim();
    final analysis = AiCategorizationEngine().analyzeNote(spokenText);
    final tagsSet = <String>{'voice-memo'};
    tagsSet.addAll(analysis.categories);

    var title = analysis.title;
    var summary = analysis.summarySnippet;
    var checklist = analysis.extractedChecklist;
    var reminders = const <Reminder>[];

    // Natural speech normally has no markdown bullets. Preserve an explicit
    // spoken task or enumeration even when a compact model is unavailable or
    // returns a plain note.
    final spokenChecklist = SpokenChecklistParser.extract(spokenText);
    if (spokenChecklist.isNotEmpty) {
      checklist = spokenChecklist
          .asMap()
          .entries
          .map(
            (entry) => CheckListItem(
              id: '${noteId ?? 'echo'}-spoken-${entry.key}',
              text: entry.value,
            ),
          )
          .toList();
      tagsSet.add('tasks');
      if (title == analysis.title) {
        title = SpokenChecklistParser.suggestedTitle(spokenText);
      }
    }

    title = VoiceNoteTitleService.concise(
      proposedTitle: title,
      spokenText: spokenText,
    );

    final deterministicReminder = SpokenReminderParser.parse(spokenText);
    if (deterministicReminder != null) {
      if (reminders.isEmpty) {
        reminders = [deterministicReminder];
      } else if (reminders.every((reminder) => reminder.triggerDate == null)) {
        reminders = reminders
            .map(
              (reminder) => Reminder(
                id: reminder.id,
                title: reminder.title,
                triggerDate: deterministicReminder.triggerDate,
                confidence: reminder.confidence,
                evidenceText: reminder.evidenceText,
              ),
            )
            .toList();
      }
    }

    if (reminders.isNotEmpty) {
      tagsSet.addAll({'reminders', 'reminder-pending'});
    }

    final note = NoteModel(
      noteId: noteId?.trim().isNotEmpty == true
          ? noteId!.trim()
          : "echo_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      contentType: NoteContentType.textOnly,
      summarySnippet: summary,
      textContent: cleanNoteText,
      createdAt: capturedAt,
      tags: tagsSet.toList(),
      checklist: checklist,
      contentBlocks: checklist.isEmpty
          ? const []
          : checklist
                .map(
                  (item) => NoteBlockData.checklist(
                    checklistId: item.id,
                    checklistText: item.text,
                    checklistCompleted: item.isCompleted,
                  ),
                )
                .toList(),
      isPinned: false,
      reminderAt: reminders
          .map((reminder) => reminder.triggerDate)
          .whereType<DateTime>()
          .firstOrNull,
    );

    await addNote(note);
    if (reminders.isNotEmpty) {
      unawaited(_scheduleVoiceRemindersInBackground(note.noteId, reminders));
    }
    final recognitionLanguage = AppPreferences.instance.speechLanguageCode;
    final actionRoute = ActionModelRouter.route(
      recognitionLanguage: recognitionLanguage,
      transcript: spokenText,
    );
    assert(actionRoute == ActionModelRoute.combined);
    unawaited(
      _enhanceVoiceNoteInBackground(
        note.noteId,
        spokenText,
        preserveSpokenChecklist: spokenChecklist.isNotEmpty,
      ),
    );
    return note;
  }

  Future<void> _scheduleVoiceRemindersInBackground(
    String noteId,
    List<Reminder> reminders,
  ) async {
    final scheduled = await _scheduleExplicitAppleReminders(reminders);
    final index = _notes.indexWhere((note) => note.noteId == noteId);
    if (index == -1) return;
    final current = _notes[index];
    final tags = current.tags.toSet()..remove('reminder-pending');
    tags.add(scheduled > 0 ? 'reminder-scheduled' : 'reminder-failed');
    await updateNote(current.copyWith(tags: tags.toList()));
  }

  Future<void> _enhanceVoiceNoteInBackground(
    String noteId,
    String spokenText, {
    required bool preserveSpokenChecklist,
  }) async {
    try {
      await ModelAvailabilityService.instance.refresh().timeout(
        const Duration(seconds: 2),
      );
      if (!ModelAvailabilityService.instance.qwen.isReady) return;
      final provider = QwenLlamaProvider.instance;
      if (!provider.isLoaded) {
        await provider.load().timeout(const Duration(seconds: 8));
      }
      final richAnalysis = await provider
          .generateNoteAnalysis(
            spokenText,
            noteId: noteId,
            noteCreatedAt: DateTime.now(),
          )
          .timeout(const Duration(seconds: 15));
      final index = _notes.indexWhere((note) => note.noteId == noteId);
      if (index == -1) return;
      final current = _notes[index];
      final enhancedChecklist = preserveSpokenChecklist
          ? current.checklist
          : richAnalysis.actionItems
                .map((item) => CheckListItem(id: item.id, text: item.task))
                .toList();
      final tags = current.tags.toSet()
        ..addAll(richAnalysis.topics)
        ..addAll(richAnalysis.suggestedTags);
      await updateNote(
        current.copyWith(
          title: richAnalysis.generatedTitle.trim().isEmpty
              ? current.title
              : VoiceNoteTitleService.concise(
                  proposedTitle: richAnalysis.generatedTitle,
                  spokenText: spokenText,
                ),
          summarySnippet: richAnalysis.summary.trim().isEmpty
              ? current.summarySnippet
              : richAnalysis.summary.trim(),
          tags: tags.toList(),
          checklist: enhancedChecklist,
          contentBlocks: enhancedChecklist
              .map(
                (item) => NoteBlockData.checklist(
                  checklistId: item.id,
                  checklistText: item.text,
                  checklistCompleted: item.isCompleted,
                ),
              )
              .toList(),
        ),
      );
    } catch (error) {
      debugPrint('Background voice-note enhancement skipped: $error');
    }
  }

  Future<int> _scheduleExplicitAppleReminders(List<Reminder> reminders) async {
    final executable = reminders
        .where(
          (reminder) =>
              reminder.triggerDate != null &&
              reminder.triggerDate!.isAfter(DateTime.now()),
        )
        .toList();
    if (executable.isEmpty) return 0;

    final bridge = AppleCalendarBridge();
    final allowed = await bridge.requestReminderPermissions();
    if (!allowed) {
      debugPrint('Apple Reminders permission was not granted.');
      return 0;
    }
    var scheduled = 0;
    for (final reminder in executable) {
      final (result, _) = await bridge.createReminder(reminder);
      if (result == CalendarWriteResult.success) {
        scheduled++;
      } else {
        debugPrint('Could not create Apple Reminder: ${reminder.title}');
      }
    }
    return scheduled;
  }

  Future<void> updateNote(NoteModel note) async {
    await initStorage();
    note = _normalizeTags(note);
    final index = _notes.indexWhere((n) => n.noteId == note.noteId);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
      await _persistNote(note);
      _scheduleNoteIndexing(note);
      unawaited(LockScreenActivityService.instance.updateIfActive(note));
    }
  }

  NoteModel _normalizeTags(NoteModel note) {
    final tags = NoteTagTaxonomy.normalize(note.tags);
    return listEquals(tags, note.tags) ? note : note.copyWith(tags: tags);
  }

  void _scheduleNoteIndexing(NoteModel note) {
    if (!_backgroundIndexingEnabled) return;
    _lastIndexingTask = _lastIndexingTask.then((_) async {
      try {
        await KnowledgeService.instance.indexNote(note);
      } catch (error) {
        debugPrint('Could not index note ${note.noteId}: $error');
      }
      try {
        await SemanticKnowledgeService.instance.indexNote(note);
      } catch (error) {
        debugPrint('Could not semantically index note ${note.noteId}: $error');
      }
    });
    unawaited(_lastIndexingTask);
  }

  @visibleForTesting
  Future<void> waitForPendingIndexingForTesting() => _lastIndexingTask;

  @visibleForTesting
  void setBackgroundIndexingForTesting(bool enabled) {
    _backgroundIndexingEnabled = enabled;
  }

  Future<void> deleteNote(String noteId) async {
    await initStorage();
    _notes.removeWhere((n) => n.noteId == noteId);
    notifyListeners();
    await _deletePersistedNote(noteId);
    try {
      await KnowledgeService.instance.removeNote(noteId);
    } catch (error) {
      debugPrint('Could not remove note $noteId from search: $error');
    }
    await SemanticKnowledgeService.instance.removeNote(noteId);
    unawaited(LockScreenActivityService.instance.remove(noteId));
  }

  Future<void> togglePin(String noteId) async {
    await initStorage();
    final index = _notes.indexWhere((n) => n.noteId == noteId);
    if (index != -1) {
      final current = _notes[index];
      _notes[index] = current.copyWith(isPinned: !current.isPinned);
      notifyListeners();
      await _persistNote(_notes[index]);
    }
  }

  Future<void> toggleCheckItem(String noteId, String itemId) async {
    await initStorage();
    final noteIndex = _notes.indexWhere((n) => n.noteId == noteId);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      final itemIndex = note.checklist.indexWhere((i) => i.id == itemId);
      if (itemIndex != -1) {
        final updatedChecklist = note.checklist
            .map(
              (item) => CheckListItem(
                id: item.id,
                text: item.text,
                isCompleted: item.id == itemId
                    ? !item.isCompleted
                    : item.isCompleted,
              ),
            )
            .toList();
        final stateById = {
          for (final item in updatedChecklist) item.id: item.isCompleted,
        };
        final updatedBlocks = note.contentBlocks
            .map(
              (block) => block.type == NoteBlockType.checklist
                  ? NoteBlockData.checklist(
                      checklistId: block.checklistId,
                      checklistText: block.checklistText,
                      checklistCompleted:
                          stateById[block.checklistId] ??
                          block.checklistCompleted,
                    )
                  : block,
            )
            .toList();
        final searchableChecklist = updatedBlocks.isNotEmpty
            ? updatedBlocks
                  .map((block) => block.searchableText)
                  .where((text) => text.trim().isNotEmpty)
                  .join('\n')
            : updatedChecklist
                  .map((item) => '${item.isCompleted ? '☑' : '☐'} ${item.text}')
                  .join('\n');
        final updated = note.copyWith(
          checklist: updatedChecklist,
          contentBlocks: updatedBlocks,
          textContent: searchableChecklist,
          summarySnippet: searchableChecklist,
        );
        _notes[noteIndex] = updated;
        notifyListeners();
        await _persistNote(updated);
        _scheduleNoteIndexing(updated);
        unawaited(LockScreenActivityService.instance.updateIfActive(updated));
      }
    }
  }

  // Automatic semantic tagging on-device using AI engine
  List<String> autoDetectTags(String content) {
    return AiCategorizationEngine().analyzeNote(content).categories;
  }

  // Ingest Uploaded PDF Document with math, tables & structural Markdown
  Future<void> ingestUploadedDocument({
    required String fileName,
    required String? filePath,
    required String extractedText,
    List<MediaAsset> mediaAssets = const [],
  }) {
    final title = fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final analysis = AiCategorizationEngine().analyzeNote(extractedText);
    final tags = List<String>.from(analysis.categories);
    if (!tags.contains("document")) tags.add("document");

    final snippet = extractedText.length > 140
        ? "${extractedText.substring(0, 140)}..."
        : extractedText;

    final note = NoteModel(
      noteId: "echo_doc_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      contentType: mediaAssets.isNotEmpty
          ? NoteContentType.richMedia
          : NoteContentType.textOnly,
      mediaAssets: mediaAssets.isNotEmpty
          ? mediaAssets
          : [
              MediaAsset(
                type: fileName.toLowerCase().endsWith(".pdf")
                    ? MediaAssetType.pdf
                    : MediaAssetType.image,
                url: filePath ?? "assets/document.pdf",
                pageCount: 4,
                caption: fileName,
                visualPreset: "pdf_doc",
              ),
            ],
      summarySnippet: snippet,
      textContent: extractedText,
      createdAt: DateTime.now(),
      tags: tags,
      isPinned: false,
    );

    return addNote(note);
  }

  // Get notes for voice assistant context carousel
  List<NoteModel> getContextualNotesForQuery(String query) {
    if (query.trim().isEmpty) {
      return _notes.take(4).toList();
    }
    final lower = query.toLowerCase();
    final matches = _notes.where((n) {
      return n.title.toLowerCase().contains(lower) ||
          n.summarySnippet.toLowerCase().contains(lower) ||
          n.textContent.toLowerCase().contains(lower) ||
          n.tags.any((t) => lower.contains(t.toLowerCase()));
    }).toList();

    if (matches.isEmpty) {
      return _notes.take(4).toList();
    }
    return matches.take(6).toList();
  }
}
