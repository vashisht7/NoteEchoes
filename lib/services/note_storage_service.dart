import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NoteStorageService {
  static const String _storageKey = 'notechoes_saved_notes_v1';
  static final NoteStorageService _instance = NoteStorageService._internal();
  factory NoteStorageService() => _instance;
  NoteStorageService._internal();

  /// Loads persisted notes from local device storage
  Future<List<NoteModel>> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(jsonString);
      final notes = decodedList.map((item) {
        return NoteModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();

      return notes;
    } catch (e) {
      debugPrint("Error loading notes from storage: $e");
      return [];
    }
  }

  /// Inserts or replaces one note by noteId.
  /// Throws if decoding or durable persistence fails.
  Future<void> upsertNote(NoteModel note) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    final List<dynamic> decodedList;
    if (jsonString == null || jsonString.isEmpty) {
      decodedList = <dynamic>[];
    } else {
      decodedList = jsonDecode(jsonString) as List<dynamic>;
    }

    final notes = decodedList
        .map(
          (item) => NoteModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    final existingIndex = notes.indexWhere(
      (existing) => existing.noteId == note.noteId,
    );

    if (existingIndex >= 0) {
      notes[existingIndex] = note;
    } else {
      // Newest voice notes appear first.
      notes.insert(0, note);
    }

    final serialized = notes.map((item) => item.toJson()).toList();
    final didPersist = await prefs.setString(
      _storageKey,
      jsonEncode(serialized),
    );

    if (!didPersist) {
      throw StateError('Failed to persist note ${note.noteId}');
    }
  }

  /// Persists all notes to local device storage
  Future<void> saveNotes(List<NoteModel> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = notes.map((n) => n.toJson()).toList();
      final jsonString = jsonEncode(serialized);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint("Error saving notes to storage: $e");
    }
  }

  /// Reads and clears any background notes written by Shortcuts or external files
  Future<List<String>> readAndClearPendingFileNotes() async {
    final pendingNotes = <String>[];
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final file = File('${docDir.path}/notechoes_pending_notes.txt');
      if (await file.exists()) {
        final lines = await file.readAsLines();
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            pendingNotes.add(line.trim());
          }
        }
        await file.delete();
      }
    } catch (e) {
      debugPrint("Error reading pending file notes: $e");
    }
    return pendingNotes;
  }

  /// Clears all local storage
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint("Error clearing storage: $e");
    }
  }
}
