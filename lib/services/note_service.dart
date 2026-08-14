import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import 'ai_categorization_engine.dart';
import 'note_storage_service.dart';
import '../ai/infrastructure/knowledge_service.dart';

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

  Future<void> _persist() {
    final snapshot = List<NoteModel>.from(_notes);
    final write = _writeTail.then(
      (_) => NoteStorageService().saveNotes(snapshot),
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
    await _persist();
    try {
      await KnowledgeService.instance.indexNote(note);
    } catch (error) {
      debugPrint('Could not index note ${note.noteId}: $error');
    }
  }

  /// Creates and saves a note directly from voice transcription or speech
  /// using the on-device AI categorization engine.
  Future<NoteModel> createFromVoiceTranscription(String spokenText) async {
    final analysis = AiCategorizationEngine().analyzeNote(spokenText);
    final tagsSet = <String>{'voice-memos', 'voice-memo'};
    tagsSet.addAll(analysis.categories);

    final note = NoteModel(
      noteId: "echo_${DateTime.now().millisecondsSinceEpoch}",
      title: analysis.title,
      contentType: NoteContentType.textOnly,
      summarySnippet: analysis.summarySnippet,
      textContent: spokenText.trim(),
      createdAt: DateTime.now(),
      tags: tagsSet.toList(),
      checklist: analysis.extractedChecklist,
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
      await _persist();
      try {
        await KnowledgeService.instance.indexNote(note);
      } catch (error) {
        debugPrint('Could not index note ${note.noteId}: $error');
      }
    }
  }

  Future<void> deleteNote(String noteId) async {
    await initStorage();
    _notes.removeWhere((n) => n.noteId == noteId);
    notifyListeners();
    await _persist();
    try {
      await KnowledgeService.instance.removeNote(noteId);
    } catch (error) {
      debugPrint('Could not remove note $noteId from search: $error');
    }
  }

  Future<void> togglePin(String noteId) async {
    await initStorage();
    final index = _notes.indexWhere((n) => n.noteId == noteId);
    if (index != -1) {
      final current = _notes[index];
      _notes[index] = current.copyWith(isPinned: !current.isPinned);
      notifyListeners();
      await _persist();
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
        await _persist();
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
