import 'dart:convert';

enum VoiceFeedbackDecision { accepted, corrected }

class VoiceFeedbackRecord {
  final int schemaVersion;
  final String feedbackId;
  final String noteId;
  final String rawTranscript;
  final String modelOutput;
  final String? correctedOutput;
  final String language;
  final String modelVersion;
  final VoiceFeedbackDecision decision;
  final DateTime createdAt;

  const VoiceFeedbackRecord({
    this.schemaVersion = 1,
    required this.feedbackId,
    required this.noteId,
    required this.rawTranscript,
    required this.modelOutput,
    this.correctedOutput,
    required this.language,
    required this.modelVersion,
    required this.decision,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'schema_version': schemaVersion,
    'feedback_id': feedbackId,
    'note_id': noteId,
    'raw_transcript': rawTranscript,
    'model_output': modelOutput,
    'corrected_output': correctedOutput,
    'language': language,
    'model_version': modelVersion,
    'decision': decision.name,
    'created_at': createdAt.toUtc().toIso8601String(),
    'upload_consent': false,
  };

  String toJsonLine() => jsonEncode(toJson());

  factory VoiceFeedbackRecord.fromJson(Map<String, dynamic> json) {
    return VoiceFeedbackRecord(
      schemaVersion: json['schema_version'] as int? ?? 1,
      feedbackId: json['feedback_id'] as String? ?? '',
      noteId: json['note_id'] as String? ?? '',
      rawTranscript: json['raw_transcript'] as String? ?? '',
      modelOutput: json['model_output'] as String? ?? '',
      correctedOutput: json['corrected_output'] as String?,
      language: json['language'] as String? ?? 'unknown',
      modelVersion: json['model_version'] as String? ?? 'unknown',
      decision: json['decision'] == VoiceFeedbackDecision.corrected.name
          ? VoiceFeedbackDecision.corrected
          : VoiceFeedbackDecision.accepted,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
