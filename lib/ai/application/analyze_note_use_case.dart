// analyze_note_use_case.dart
// Orchestrates LLM note analysis with fallback to the legacy engine.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import '../providers/text_generation_provider.dart';
import '../domain/note_analysis.dart';
import '../config/ai_feature_flags.dart';
import '../infrastructure/ai_database.dart';
import '../infrastructure/ai_job_queue.dart';
import '../../models/note_model.dart';
import '../../services/ai_categorization_engine.dart' as legacy;

class AnalyzeNoteUseCase {
  final TextGenerationProvider llm;
  final AiDatabase database;
  final AiJobQueue? jobQueue;

  AnalyzeNoteUseCase(this.llm, this.database, {this.jobQueue});

  Future<NoteAnalysisResult> execute(NoteModel note,
      {bool forceRefresh = false}) async {
    final sourceHash =
        md5.convert(utf8.encode(note.textContent)).toString();

    // Bypass AI if flag is off
    if (!AiFeatureFlags.instance.noteAnalysisEnabled) {
      return _legacyFallback(note);
    }

    // Return cached result if source hasn't changed
    if (!forceRefresh) {
      final existing = await database.getAnalysisForNote(note.noteId);
      if (existing != null && existing.sourceHash == sourceHash) {
        return _fromRow(existing, note.noteId);
      }
    }

    // Enqueue a tracking job if queue is available
    if (jobQueue != null) {
      await jobQueue!.enqueue(
        jobType: 'note_analysis',
        sourceId: note.noteId,
        sourceHash: sourceHash,
        modelVersion: llm.modelVersion,
      );
    }

    final result = await llm.generateNoteAnalysis(
      note.textContent,
      noteId: note.noteId,
      noteCreatedAt: note.createdAt,
      existingTranscript: null,
    );

    // Persist to Drift
    await database.upsertAnalysis(
      AiNoteAnalysisTableCompanion(
        noteId: Value(result.noteId),
        modelVersion: Value(result.modelVersion),
        sourceHash: Value(sourceHash),
        detectedLanguage: Value(result.detectedLanguage),
        generatedTitle: Value(result.generatedTitle),
        summary: Value(result.summary),
        englishRetrievalSummary: Value(result.englishRetrievalSummary),
        topicsJson: Value(jsonEncode(result.topics)),
        peopleJson: Value(jsonEncode(result.people)),
        placesJson: Value(jsonEncode(result.places)),
        suggestedTagsJson: Value(jsonEncode(result.suggestedTags)),
        actionItemsJson:
            Value(jsonEncode(result.actionItems.map((e) => e.toJson()).toList())),
        eventsJson:
            Value(jsonEncode(result.events.map((e) => e.toJson()).toList())),
        remindersJson:
            Value(jsonEncode(result.reminders.map((e) => e.toJson()).toList())),
        travelDetailsJson: Value(
            jsonEncode(result.travelDetails.map((e) => e.toJson()).toList())),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // Update FTS5 index
    await database.ftsUpsert(
      sourceId: result.noteId,
      sourceType: 'note',
      title: result.generatedTitle,
      originalText: note.textContent,
      englishRetrievalText: result.englishRetrievalSummary,
      keywords: result.topics.join(' '),
      people: result.people.join(' '),
      places: result.places.join(' '),
    );

    return result;
  }

  NoteAnalysisResult _legacyFallback(NoteModel note) {
    final r = legacy.AiCategorizationEngine().analyzeNote(note.textContent);
    return NoteAnalysisResult(
      noteId: note.noteId,
      modelVersion: 'fallback-engine',
      detectedLanguage: 'en',
      noteType: NoteType.general,
      generatedTitle: r.title,
      summary: r.summarySnippet,
      englishRetrievalSummary: r.summarySnippet,
      topics: r.categories,
      suggestedTags: r.categories,
      actionItems: r.extractedChecklist
          .map((c) => ActionItem(
                id: c.id,
                task: c.text,
                confidence: 0.6,
                evidenceText: c.text,
              ))
          .toList(),
      analysedAt: DateTime.now(),
    );
  }

  NoteAnalysisResult _fromRow(
      AiNoteAnalysisTableData row, String noteId) {
    List<T> _decode<T>(
        String? json, T Function(Map<String, dynamic>) fromJson) {
      if (json == null) return <T>[];
      try {
        return (jsonDecode(json) as List<dynamic>)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return <T>[];
      }
    }

    List<String> _decodeStrings(String? json) {
      if (json == null) return <String>[];
      try {
        return (jsonDecode(json) as List<dynamic>)
            .map((e) => e as String)
            .toList();
      } catch (_) {
        return <String>[];
      }
    }

    return NoteAnalysisResult(
      noteId: noteId,
      modelVersion: row.modelVersion,
      detectedLanguage: row.detectedLanguage,
      noteType: NoteType.general,
      generatedTitle: row.generatedTitle ?? '',
      summary: row.summary ?? '',
      englishRetrievalSummary: row.englishRetrievalSummary ?? '',
      topics: _decodeStrings(row.topicsJson),
      people: _decodeStrings(row.peopleJson),
      places: _decodeStrings(row.placesJson),
      suggestedTags: _decodeStrings(row.suggestedTagsJson),
      actionItems:
          _decode(row.actionItemsJson, ActionItem.fromJson),
      events: _decode(row.eventsJson, CalendarEvent.fromJson),
      reminders: _decode(row.remindersJson, Reminder.fromJson),
      travelDetails:
          _decode(row.travelDetailsJson, TravelDetail.fromJson),
      analysedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }
}
