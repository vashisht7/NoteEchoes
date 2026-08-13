// text_generation_provider.dart
// Abstract interface for local LLM text generation.
// Implementations: QwenLlamaProvider, AppleIntelligenceProvider (iOS 26+).

import '../domain/ai_models.dart';
import '../domain/note_analysis.dart';

/// Reasons a generation request may fail.
enum GenerationErrorCode {
  modelNotLoaded,
  contextTooLong,
  memoryPressure,
  thermalThrottle,
  invalidSchema,
  timeout,
  cancelled,
  unknown,
}

class GenerationException implements Exception {
  final GenerationErrorCode code;
  final String message;
  const GenerationException(this.code, this.message);

  @override
  String toString() => 'GenerationException($code): $message';
}

/// Abstract interface for local text generation.
///
/// Providers must be thread-safe. A provider may only serve one
/// concurrent generation request at a time.
abstract class TextGenerationProvider {
  /// Display name shown in settings, e.g. "Qwen 3.5-0.8B Q4_K_M".
  String get displayName;

  /// Model version string for provenance tracking.
  String get modelVersion;

  /// Whether the model is currently loaded and ready.
  bool get isLoaded;

  /// Load the model from disk. No-op if already loaded.
  /// Throws [GenerationException] if the model file is missing or corrupt.
  Future<void> load();

  /// Unload the model from memory. No-op if not loaded.
  Future<void> unload();

  /// Generate a text completion.
  ///
  /// [messages] is the full conversation context.
  /// [options] controls sampling parameters.
  ///
  /// Throws [GenerationException] on failure.
  Future<String> generate(
    List<AiMessage> messages, {
    GenerationOptions options = const GenerationOptions(),
    void Function(String token)? onToken,
  });

  /// Generate a response and parse it as [NoteAnalysisResult].
  ///
  /// Will attempt one repair pass if the first response is invalid JSON
  /// before throwing.
  Future<NoteAnalysisResult> generateNoteAnalysis(
    String noteContent, {
    required String noteId,
    required DateTime noteCreatedAt,
    String? existingTranscript,
  });

  /// True if the provider supports streaming token output.
  bool get supportsStreaming;
}
