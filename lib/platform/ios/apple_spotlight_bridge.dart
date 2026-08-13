import 'dart:io';
import 'package:flutter/services.dart';
import '../../models/note_model.dart';

class AppleSpotlightBridge {
  static final AppleSpotlightBridge instance = AppleSpotlightBridge._();
  AppleSpotlightBridge._();

  static const MethodChannel _channel = MethodChannel('notechoes/spotlight');

  Future<void> indexNote(NoteModel note) async {
    if (!Platform.isIOS) return;

    // Only indexes non-private notes (notes without '#private' tag).
    if (note.tags.contains('#private') ||
        note.textContent.contains('#private')) {
      return;
    }

    try {
      await _channel.invokeMethod('indexItem', {
        'noteId': note.noteId,
        'title': note.title,
        'summarySnippet': note.textContent.length > 200
            ? note.textContent.substring(0, 200)
            : note.textContent,
      });
    } catch (e) {
      // Fallback/log
    }
  }

  Future<void> deindexNote(String noteId) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('deindexItem', {'noteId': noteId});
    } catch (e) {
      // Fallback
    }
  }

  Future<void> deindexAll() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('deindexAll');
    } catch (e) {
      // Fallback
    }
  }
}
