import 'package:flutter/foundation.dart';
import '../models/note_model.dart';

class NoteService extends ChangeNotifier {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;

  NoteService._internal();

  // Clean starting state: empty by default
  final List<NoteModel> _notes = [];
  String _searchQuery = '';
  String _selectedTag = 'All';
  bool _isSignedIn = false;
  String? _userEmail;
  String? _authProvider; // "apple" or "google"

  bool get isSignedIn => _isSignedIn;
  String? get userEmail => _userEmail;
  String? get authProvider => _authProvider;

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

  List<NoteModel> get notes {
    var filtered = _notes.where((note) {
      final matchesTag = _selectedTag == 'All' || note.tags.contains(_selectedTag);
      final matchesQuery = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.summarySnippet.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.textContent.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
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

  void addNote(NoteModel note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void updateNote(NoteModel note) {
    final index = _notes.indexWhere((n) => n.noteId == note.noteId);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  void deleteNote(String noteId) {
    _notes.removeWhere((n) => n.noteId == noteId);
    notifyListeners();
  }

  void togglePin(String noteId) {
    final index = _notes.indexWhere((n) => n.noteId == noteId);
    if (index != -1) {
      final current = _notes[index];
      _notes[index] = current.copyWith(isPinned: !current.isPinned);
      notifyListeners();
    }
  }

  void toggleCheckItem(String noteId, String itemId) {
    final noteIndex = _notes.indexWhere((n) => n.noteId == noteId);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      final itemIndex = note.checklist.indexWhere((i) => i.id == itemId);
      if (itemIndex != -1) {
        note.checklist[itemIndex].isCompleted = !note.checklist[itemIndex].isCompleted;
        notifyListeners();
      }
    }
  }

  // Automatic semantic tagging on-device
  List<String> autoDetectTags(String content) {
    final lower = content.toLowerCase();
    final detected = <String>{};

    if (lower.contains("math") || lower.contains("equation") || lower.contains("formula") || lower.contains(r"$$") || lower.contains(r"\int")) {
      detected.add("math");
    }
    if (lower.contains("pdf") || lower.contains("document") || lower.contains("table") || lower.contains("spec")) {
      detected.add("pdf-doc");
    }
    if (lower.contains("milk") || lower.contains("grocery") || lower.contains("coffee") || lower.contains("buy") || lower.contains("pantry")) {
      detected.add("grocery");
    }
    if (lower.contains("todo") || lower.contains("task") || lower.contains("sprint") || lower.contains("fix") || lower.contains("due")) {
      detected.add("tasks");
    }
    if (lower.contains("design") || lower.contains("ui") || lower.contains("layout") || lower.contains("color") || lower.contains("token")) {
      detected.add("design");
    }
    if (lower.contains("voice") || lower.contains("audio") || lower.contains("speak") || lower.contains("memo")) {
      detected.add("voice-memo");
    }

    if (detected.isEmpty) {
      detected.add("notes");
    }
    return detected.toList();
  }

  // Ingest Uploaded PDF Document with math, tables & structural Markdown
  void ingestUploadedDocument({
    required String fileName,
    required String? filePath,
    required String extractedText,
    List<MediaAsset> mediaAssets = const [],
  }) {
    final title = fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    final tags = autoDetectTags(extractedText);
    tags.add("document");

    final snippet = extractedText.length > 140
        ? "${extractedText.substring(0, 140)}..."
        : extractedText;

    final note = NoteModel(
      noteId: "echo_doc_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      contentType: mediaAssets.isNotEmpty ? NoteContentType.richMedia : NoteContentType.textOnly,
      mediaAssets: mediaAssets.isNotEmpty
          ? mediaAssets
          : [
              MediaAsset(
                type: fileName.toLowerCase().endsWith(".pdf") ? MediaAssetType.pdf : MediaAssetType.image,
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

    addNote(note);
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
