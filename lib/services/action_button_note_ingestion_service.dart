import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'note_service.dart';
import 'voice_capture_validator.dart';

/// Drains the `PendingVoiceNoteStore` queue that is populated by the
/// `TranscribeAudioNoteIntent` Shortcuts action and writes each pending
/// note into [NoteService].
///
/// IMPORTANT: MethodChannels require a live [FlutterViewController]. Do NOT
/// call [initialize] or [importPendingNotes] before [runApp] completes —
/// calls made that early silently return null and no notes are imported.
/// [HomeScreen] calls [initialize] from its [State.initState] which runs
/// on the first frame after [runApp], so the channel is always ready.
final class ActionButtonNoteIngestionService with WidgetsBindingObserver {
  ActionButtonNoteIngestionService._();

  static final ActionButtonNoteIngestionService instance =
      ActionButtonNoteIngestionService._();

  static const MethodChannel _channel = MethodChannel(
    'com.vashisht.notechoes/action_button',
  );

  bool _isImporting = false;
  bool _observerAttached = false;

  /// Called from [HomeScreen.initState]. Safe to call multiple times.
  Future<void> initialize() async {
    if (!_observerAttached) {
      _observerAttached = true;
      WidgetsBinding.instance.addObserver(this);
    }
    await importPendingNotes();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(importPendingNotes());
    }
  }

  /// Drains the pending note queue one-by-one until it is empty.
  Future<void> importPendingNotes() async {
    if (_isImporting) return;
    _isImporting = true;

    try {
      // Ensure NoteService storage is ready before writing
      await NoteService().initStorage();

      int imported = 0;
      while (true) {
        final pending = await _channel.invokeMapMethod<String, dynamic>(
          'peekPendingActionButtonNote',
        );

        // null means the queue is empty — we are done
        if (pending == null) break;

        final id = pending['id'] as String? ?? '';
        final text = (pending['text'] as String? ?? '').trim();
        final createdAt =
            DateTime.tryParse(pending['createdAt'] as String? ?? '') ??
            DateTime.now();

        // Always acknowledge even if text is empty, to avoid infinite loops
        if (!VoiceCaptureValidator.hasMeaningfulSpeech(text)) {
          await _acknowledge(id);
          continue;
        }

        await NoteService().createFromVoiceTranscription(
          text,
          noteId: id,
          createdAt: createdAt,
        );

        // Acknowledge only after the note is durably committed. If persistence
        // fails, the App Intent queue retains the item for the next launch.
        await _acknowledge(id);
        imported++;
        debugPrint('notechoes: imported voice note "$id" ($imported so far)');
      }

      if (imported > 0) {
        debugPrint('notechoes: finished importing $imported voice note(s)');
      }
    } on PlatformException catch (error) {
      debugPrint(
        'notechoes: Action Button import PlatformException: '
        '${error.code} — ${error.message}',
      );
    } catch (error, stack) {
      debugPrint('notechoes: Action Button import error: $error\n$stack');
    } finally {
      _isImporting = false;
    }
  }

  Future<void> _acknowledge(String id) async {
    if (id.isEmpty) return;
    await _channel.invokeMethod<void>(
      'acknowledgePendingActionButtonNote',
      <String, Object>{'id': id},
    );
  }
}
