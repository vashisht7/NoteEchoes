import 'dart:convert';
import 'package:flutter/foundation.dart';
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
