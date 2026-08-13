// transcription_provider.dart
// Abstract interface for local speech-to-text transcription.
// Implementation: DolphinSherpaProvider.

import '../domain/transcript.dart';
import '../domain/ai_models.dart';

/// Errors specific to ASR.
enum TranscriptionErrorCode {
  modelNotLoaded,
  audioFormatUnsupported,
  audioTooShort,
  audioTooLong,
  cancelled,
  unknown,
}

class TranscriptionException implements Exception {
  final TranscriptionErrorCode code;
  final String message;
  const TranscriptionException(this.code, this.message);

  @override
  String toString() => 'TranscriptionException($code): $message';
}

/// Abstract interface for local speech-to-text.
abstract class TranscriptionProvider {
  /// Display name, e.g. "Dolphin Base INT8".
  String get displayName;

  /// Model version string.
  String get modelVersion;

  /// Whether the ASR model is currently loaded.
  bool get isLoaded;

  /// Load ASR model. No-op if already loaded.
  Future<void> load();

  /// Unload ASR model.
  Future<void> unload();

  /// Transcribe an audio file at [audioFilePath].
  ///
  /// Audio must be mono WAV/PCM at 16 kHz.
  /// If [language] is [AudioLanguage.auto], the provider detects
  /// the language per segment.
  ///
  /// Emits incremental [TranscriptSegment]s via [onSegment] as they
  /// are decoded; the final [TranscriptResult] is returned.
  ///
  /// Throws [TranscriptionException] on unrecoverable error.
  Future<TranscriptResult> transcribe(
    String audioFilePath, {
    required String noteId,
    AudioLanguage language = AudioLanguage.auto,
    void Function(TranscriptSegment segment)? onSegment,
    void Function(double progress)? onProgress,
  });

  /// Cancel the in-progress transcription for the given note.
  /// Segments already decoded are preserved.
  Future<void> cancel(String noteId);

  /// Whether multi-language auto-detection is supported.
  bool get supportsAutoLanguage;

  /// Supported language codes.
  List<String> get supportedLanguages;
}
