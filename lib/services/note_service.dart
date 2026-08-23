import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import 'ai_categorization_engine.dart';
import 'spoken_checklist_parser.dart';
import 'note_storage_service.dart';
import '../ai/infrastructure/knowledge_service.dart';
import '../ai/infrastructure/model_availability_service.dart';
import '../ai/infrastructure/qwen_llama_provider.dart';
import '../ai/infrastructure/semantic_knowledge_service.dart';

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
        _notes.add(note);
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
        _notes.add(note);
        changed = true;
      }
    }
    if (changed) notifyListeners();
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
    _selectedTag = tag;
    notifyListeners();
  }

  Future<void> addNote(NoteModel note) async {
    await initStorage();
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
    final analysis = AiCategorizationEngine().analyzeNote(spokenText);
    final tagsSet = <String>{'voice-memo'};
    tagsSet.addAll(analysis.categories);

    var title = analysis.title;
    var summary = analysis.summarySnippet;
    var checklist = analysis.extractedChecklist;

    // A verified Qwen installation upgrades spoken notes from keyword rules to
    // content-aware titles, topics and action extraction. The lightweight path
    // remains available when no model is downloaded.
    try {
      await ModelAvailabilityService.instance.refresh();
    } catch (error) {
      debugPrint('Could not refresh local model status: $error');
    }

    if (ModelAvailabilityService.instance.qwen.isReady) {
      try {
        final provider = QwenLlamaProvider.instance;
        if (!provider.isLoaded) await provider.load();
        final richAnalysis = await provider.generateNoteAnalysis(
          spokenText,
          noteId: 'voice-preview-${DateTime.now().microsecondsSinceEpoch}',
          noteCreatedAt: DateTime.now(),
        );
        if (richAnalysis.generatedTitle.trim().isNotEmpty) {
          title = richAnalysis.generatedTitle.trim();
        }
        if (richAnalysis.summary.trim().isNotEmpty) {
          summary = richAnalysis.summary.trim();
        }
        tagsSet.addAll(richAnalysis.topics);
        tagsSet.addAll(richAnalysis.suggestedTags);
        checklist = richAnalysis.actionItems
            .map((item) => CheckListItem(id: item.id, text: item.task))
            .toList();
      } catch (error) {
        debugPrint('Enhanced voice-note categorization fell back: $error');
      }
    }

    // Natural speech normally has no markdown bullets. Preserve an explicit
    // spoken enumeration ("first task ... second ...") even when a compact
    // model or the offline fallback returns a single task/plain note.
    final spokenChecklist = SpokenChecklistParser.extract(spokenText);
    if (spokenChecklist.length >= 2) {
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
      if (title == analysis.title) title = 'Checklist';
    }

    final note = NoteModel(
      noteId: noteId?.trim().isNotEmpty == true
          ? noteId!.trim()
          : "echo_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      contentType: NoteContentType.textOnly,
      summarySnippet: summary,
      textContent: spokenText.trim(),
      createdAt: createdAt ?? DateTime.now(),
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
    );

    await addNote(note);
    return note;
  }

  Future<void> updateNote(NoteModel note) async {
    await initStorage();
    final index = _notes.indexWhere((n) => n.noteId == note.noteId);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
      await _persistNote(note);
      _scheduleNoteIndexing(note);
    }
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
        note.checklist[itemIndex].isCompleted =
            !note.checklist[itemIndex].isCompleted;
        notifyListeners();
        await _persistNote(note);
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
