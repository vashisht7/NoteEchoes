import 'dart:io';

import 'package:flutter/services.dart';

import '../models/note_model.dart';

class LockScreenActivityService {
  LockScreenActivityService._();

  static final instance = LockScreenActivityService._();
  static const _channel = MethodChannel('noteechoes/lock_screen_activity');

  Future<bool> isActive(String noteId) async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod<bool>('isActive', {
            'noteId': noteId,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> show(NoteModel note) async {
    if (!Platform.isIOS) {
      throw PlatformException(
        code: 'LIVE_ACTIVITY_UNAVAILABLE',
        message: 'Lock Screen notes are available on iPhone.',
      );
    }
    await _channel.invokeMethod<String>('show', _payload(note));
  }

  Future<void> remove(String noteId) async {
    if (!Platform.isIOS) return;
    await _channel.invokeMethod<bool>('remove', {'noteId': noteId});
  }

  Future<void> updateIfActive(NoteModel note) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<bool>('update', _payload(note));
    } catch (_) {}
  }

  Map<String, dynamic> _payload(NoteModel note) {
    final completed = note.checklist.where((item) => item.isCompleted).length;
    return {
      'noteId': note.noteId,
      'title': note.title,
      'subtitle': note.checklist.isNotEmpty
          ? '$completed of ${note.checklist.length} completed'
          : (note.summarySnippet.isNotEmpty
                ? note.summarySnippet
                : note.textContent),
      'items': note.checklist
          .where((item) => !item.isCompleted)
          .map((item) => item.text)
          .take(3)
          .toList(),
      'completed': completed,
      'total': note.checklist.length,
    };
  }
}
