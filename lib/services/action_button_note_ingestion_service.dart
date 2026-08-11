import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/note_model.dart';
import 'ai_categorization_engine.dart';
import 'note_service.dart';

final class ActionButtonNoteIngestionService
    with WidgetsBindingObserver {
  ActionButtonNoteIngestionService._();

  static final ActionButtonNoteIngestionService instance =
      ActionButtonNoteIngestionService._();

  static const MethodChannel _channel = MethodChannel(
    'com.vashisht.notechoes/action_button',
  );

  final AiCategorizationEngine _categorizationEngine =
      AiCategorizationEngine();

  bool _isImporting = false;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addObserver(this);
    await importPendingNotes();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(importPendingNotes());
    }
  }

  Future<void> importPendingNotes() async {
    if (_isImporting) return;
    _isImporting = true;

    try {
      while (true) {
        final pending =
            await _channel.invokeMapMethod<String, dynamic>(
          'peekPendingActionButtonNote',
        );

        if (pending == null) return;

        final id = pending['id'] as String;
        final text = (pending['text'] as String).trim();
        final createdAt = DateTime.tryParse(
              pending['createdAt'] as String? ?? '',
            ) ??
            DateTime.now();

        if (text.isEmpty) {
          await _acknowledge(id);
          continue;
        }

        final analysis = _categorizationEngine.analyzeNote(text);

        // Ensure both 'voice-memos' and 'voice-memo' tags are present for filter tabs
        final tagsSet = <String>{'voice-memos', 'voice-memo'};
        tagsSet.addAll(analysis.categories);

        final note = NoteModel(
          noteId: id,
          title: analysis.title,
          contentType: analysis.contentType,
          mediaAssets: const [],
          summarySnippet: analysis.summarySnippet,
          textContent: text,
          createdAt: createdAt,
          tags: tagsSet.toList(),
          isPinned: false,
          checklist: analysis.extractedChecklist,
        );

        // Add to NoteService so in-memory list updates and notifyListeners() fires to update UI immediately
        NoteService().addNote(note);
        await _acknowledge(id);
      }
    } on PlatformException catch (error, stackTrace) {
      debugPrint(
        'Action Button pending-note import failed: '
        '${error.code} ${error.message}\n$stackTrace',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Action Button pending-note import failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isImporting = false;
    }
  }

  Future<void> _acknowledge(String id) {
    return _channel.invokeMethod<void>(
      'acknowledgePendingActionButtonNote',
      <String, Object>{'id': id},
    );
  }
}
