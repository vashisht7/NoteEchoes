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
    await _channel.invokeMethod<String>('show', buildPayload(note));
  }

  Future<void> remove(String noteId) async {
    if (!Platform.isIOS) return;
    await _channel.invokeMethod<bool>('remove', {'noteId': noteId});
  }

  Future<void> updateIfActive(NoteModel note) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<bool>('update', buildPayload(note));
    } catch (_) {}
  }

  /// Returns durable checklist changes made from the Lock Screen and clears
  /// the native queue only after it has been transferred to Flutter.
  Future<List<Map<String, dynamic>>> consumeChecklistActions() async {
    if (!Platform.isIOS) return const [];
    try {
      final values =
          await _channel.invokeMethod<List<dynamic>>(
            'consumeChecklistActions',
          ) ??
          const [];
      return values
          .whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Sends the complete checklist to the native shared store. ActivityKit only
  /// renders three pending rows, but the native intent needs the remaining rows
  /// so it can rotate the next one into view immediately after a Lock Screen
  /// check-off.
  Map<String, dynamic> buildPayload(NoteModel note) {
    final completed = note.checklist.where((item) => item.isCompleted).length;
    return {
      'noteId': note.noteId,
      'title': note.title,
      'subtitle': note.checklist.isNotEmpty
          ? '$completed of ${note.checklist.length} completed'
          : (note.textContent.isNotEmpty
                ? note.textContent
                : note.summarySnippet),
      'items': note.checklist
          .map(
            (item) => {
              'id': item.id,
              'text': item.text,
              'isCompleted': item.isCompleted,
            },
          )
          .toList(),
      'completed': completed,
      'total': note.checklist.length,
    };
  }
}
