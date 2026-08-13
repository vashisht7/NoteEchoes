// transcribe_note_use_case.dart
// Orchestrates audio transcription: creates a job, runs ASR,
// persists each segment, and updates the job state.

import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../providers/transcription_provider.dart';
import '../domain/transcript.dart';
import '../domain/ai_models.dart';
import '../infrastructure/ai_database.dart';

class TranscribeNoteUseCase {
  final TranscriptionProvider transcriptionProvider;
  final AiDatabase database;

  TranscribeNoteUseCase(this.transcriptionProvider, this.database);

  Future<TranscriptResult> execute(
    String audioFilePath,
    String noteId, {
    AudioLanguage language = AudioLanguage.auto,
    void Function(TranscriptSegment)? onSegment,
    void Function(double)? onProgress,
  }) async {
    final jobId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Create a queued job record
    await database.upsertJob(
      AiJobsTableCompanion(
        id: Value(jobId),
        jobType: const Value('transcription'),
        sourceId: Value(noteId),
        sourceHash: const Value(''),
        modelVersion: Value(transcriptionProvider.modelVersion),
        status: const Value('queued'),
        createdAt: Value(now),
      ),
    );

    // Mark running
    await database.updateJobStatus(jobId, 'running',
        progress: 0.0, completedAt: null);

    try {
      final result = await transcriptionProvider.transcribe(
        audioFilePath,
        noteId: noteId,
        language: language,
        onSegment: (segment) async {
          onSegment?.call(segment);

          // Persist segment immediately (crash-safe)
          await database.insertSegment(
            TranscriptSegmentsTableCompanion(
              id: Value(const Uuid().v4()),
              noteId: Value(noteId),
              startMs: Value(segment.startMs),
              endMs: Value(segment.endMs),
              language: Value(segment.language.bcp47),
              segmentText: Value(segment.text),
              confidence: Value(segment.confidence),
              speakerLabel: Value(segment.speakerLabel),
              sequenceNumber: Value(segment.sequenceNumber),
            ),
          );
        },
        onProgress: onProgress,
      );

      await database.updateJobStatus(
        jobId,
        'completed',
        progress: 1.0,
        completedAt: DateTime.now().millisecondsSinceEpoch,
      );

      return result;
    } catch (e) {
      final errorCode = e is TranscriptionException
          ? e.code.name
          : 'unknown';

      await database.updateJobStatus(jobId, 'failed',
          errorCode: errorCode,
          completedAt: DateTime.now().millisecondsSinceEpoch);
      rethrow;
    }
  }
}
