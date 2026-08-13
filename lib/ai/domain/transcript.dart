// transcript.dart
// Typed transcript data model for Dolphin ASR output.

import 'ai_models.dart';

/// One recognised segment from a speech recording.
class TranscriptSegment {
  final int startMs;
  final int endMs;
  final String text;
  final AudioLanguage language;
  final double confidence; // 0.0 – 1.0
  final String? speakerLabel; // null unless diarisation enabled
  final int sequenceNumber;

  const TranscriptSegment({
    required this.startMs,
    required this.endMs,
    required this.text,
    required this.language,
    required this.confidence,
    this.speakerLabel,
    required this.sequenceNumber,
  });

  Duration get start => Duration(milliseconds: startMs);
  Duration get end => Duration(milliseconds: endMs);
  Duration get duration => Duration(milliseconds: endMs - startMs);

  Map<String, dynamic> toJson() => {
        'start_ms': startMs,
        'end_ms': endMs,
        'text': text,
        'language': language.bcp47,
        'confidence': confidence,
        if (speakerLabel != null) 'speaker_label': speakerLabel,
        'sequence_number': sequenceNumber,
      };

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      startMs: json['start_ms'] as int,
      endMs: json['end_ms'] as int,
      text: json['text'] as String,
      language:
          AudioLanguageExt.fromBcp47(json['language'] as String? ?? 'auto'),
      confidence: (json['confidence'] as num).toDouble(),
      speakerLabel: json['speaker_label'] as String?,
      sequenceNumber: json['sequence_number'] as int,
    );
  }
}

/// The complete output of a speech-to-text pass on one recording.
class TranscriptResult {
  final String noteId;
  final List<TranscriptSegment> segments;
  final AudioLanguage dominantLanguage;
  final String modelVersion;
  final double realTimeFactor;

  const TranscriptResult({
    required this.noteId,
    required this.segments,
    required this.dominantLanguage,
    required this.modelVersion,
    this.realTimeFactor = 0.0,
  });

  /// Full concatenated transcript text, preserving original line structure.
  String get fullText => segments.map((s) => s.text.trim()).join(' ');

  /// Total duration of the recording.
  Duration get totalDuration {
    if (segments.isEmpty) return Duration.zero;
    return Duration(milliseconds: segments.last.endMs);
  }

  Map<String, dynamic> toJson() => {
        'note_id': noteId,
        'segments': segments.map((s) => s.toJson()).toList(),
        'dominant_language': dominantLanguage.bcp47,
        'model_version': modelVersion,
        'real_time_factor': realTimeFactor,
      };
}
