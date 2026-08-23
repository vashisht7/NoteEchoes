// ai_models.dart
// Shared domain types used across all AI providers and use cases.

/// The language of a recorded or transcribed audio segment.
enum AudioLanguage {
  english,
  telugu,
  teluguEnglishMixed,
  hindi,
  auto, // Provider detects per-segment
}

extension AudioLanguageExt on AudioLanguage {
  String get bcp47 {
    switch (this) {
      case AudioLanguage.english:
        return 'en';
      case AudioLanguage.telugu:
        return 'te';
      case AudioLanguage.teluguEnglishMixed:
        return 'te-en-mixed';
      case AudioLanguage.hindi:
        return 'hi';
      case AudioLanguage.auto:
        return 'auto';
    }
  }

  String get displayName {
    switch (this) {
      case AudioLanguage.english:
        return 'English';
      case AudioLanguage.telugu:
        return 'Telugu';
      case AudioLanguage.teluguEnglishMixed:
        return 'Telugu & English Mixed';
      case AudioLanguage.hindi:
        return 'Hindi';
      case AudioLanguage.auto:
        return 'Auto-detect';
    }
  }

  static AudioLanguage fromBcp47(String code) {
    final lower = code.toLowerCase().trim();
    if (lower == 'te-en-mixed' || lower == 'te-en' || lower == 'mixed') {
      return AudioLanguage.teluguEnglishMixed;
    }
    switch (lower.split('-').first) {
      case 'en':
        return AudioLanguage.english;
      case 'te':
        return AudioLanguage.telugu;
      case 'hi':
        return AudioLanguage.hindi;
      default:
        return AudioLanguage.auto;
    }
  }
}

/// Rich transcription provenance recording engine, language mode, quality, and fallback telemetry.
class TranscriptionProvenance {
  final String text;
  final String requestedMode;
  final String detectedLanguage;
  final String engine;
  final String model;
  final bool fallbackUsed;
  final String? fallbackReason;
  final Map<String, dynamic> quality;

  const TranscriptionProvenance({
    required this.text,
    required this.requestedMode,
    required this.detectedLanguage,
    required this.engine,
    required this.model,
    this.fallbackUsed = false,
    this.fallbackReason,
    this.quality = const {},
  });

  factory TranscriptionProvenance.fromNative(dynamic raw) {
    if (raw is String) {
      return TranscriptionProvenance(
        text: raw,
        requestedMode: 'auto',
        detectedLanguage: 'auto',
        engine: 'whisperkit',
        model: 'base',
      );
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      return TranscriptionProvenance(
        text: map['text'] as String? ?? '',
        requestedMode: map['requestedMode'] as String? ?? 'auto',
        detectedLanguage: map['detectedLanguage'] as String? ?? 'auto',
        engine: map['engine'] as String? ?? 'whisperkit',
        model: map['model'] as String? ?? 'base',
        fallbackUsed: map['fallbackUsed'] == true,
        fallbackReason: map['fallbackReason'] as String?,
        quality: map['quality'] is Map
            ? Map<String, dynamic>.from(map['quality'] as Map)
            : const {},
      );
    }
    return const TranscriptionProvenance(
      text: '',
      requestedMode: 'auto',
      detectedLanguage: 'auto',
      engine: 'unknown',
      model: 'unknown',
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'requestedMode': requestedMode,
    'detectedLanguage': detectedLanguage,
    'engine': engine,
    'model': model,
    'fallbackUsed': fallbackUsed,
    if (fallbackReason != null) 'fallbackReason': fallbackReason,
    'quality': quality,
  };
}

/// The scope of a cross-note retrieval search.
enum RetrievalScope {
  /// All non-private notes.
  allNotes,

  /// A specific notebook.
  notebook,

  /// A single document.
  document,

  /// A single note.
  singleNote,
}

/// A single message in an AI conversation.
class AiMessage {
  final AiRole role;
  final String content;

  const AiMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role.name, 'content': content};
}

enum AiRole { system, user, assistant }

/// Options controlling text generation.
class GenerationOptions {
  final int maxTokens;
  final double temperature;
  final double topP;
  final int topK;
  final List<String> stopSequences;
  final bool thinkingEnabled;

  const GenerationOptions({
    this.maxTokens = 512,
    this.temperature = 0.2,
    this.topP = 0.9,
    this.topK = 40,
    this.stopSequences = const [],
    this.thinkingEnabled = false,
  });

  /// Conservative options for structured JSON extraction.
  static const structured = GenerationOptions(
    maxTokens: 1024,
    temperature: 0.0,
    topP: 0.95,
    topK: 10,
    thinkingEnabled: false,
  );

  /// Options for chat responses.
  static const chat = GenerationOptions(
    maxTokens: 768,
    temperature: 0.6,
    topP: 0.9,
    topK: 40,
  );
}

/// Progress report from a running AI operation.
class AiProgress {
  final double fractionCompleted; // 0.0 – 1.0
  final String statusMessage;

  const AiProgress({
    required this.fractionCompleted,
    required this.statusMessage,
  });
}

/// The state of a model's local installation.
enum ModelInstallationState {
  notInstalled,
  downloading,
  verifying,
  installed,
  updateAvailable,
  corrupted,
  failed,
}

/// Provenance metadata recorded for every AI operation.
class AiProvenance {
  final String modelId;
  final String modelVersion;
  final String promptVersion;
  final int schemaVersion;
  final double confidence;
  final String rawOutput;
  final String? validatedOutput;
  final bool isConfirmed;
  final DateTime timestamp;

  AiProvenance({
    required this.modelId,
    required this.modelVersion,
    required this.promptVersion,
    required this.schemaVersion,
    required this.confidence,
    required this.rawOutput,
    this.validatedOutput,
    this.isConfirmed = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'model_id': modelId,
    'model_version': modelVersion,
    'prompt_version': promptVersion,
    'schema_version': schemaVersion,
    'confidence': confidence,
    'raw_output': rawOutput,
    'validated_output': validatedOutput,
    'is_confirmed': isConfirmed,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AiProvenance.fromJson(Map<String, dynamic> json) => AiProvenance(
    modelId: json['model_id'] as String? ?? 'unknown',
    modelVersion: json['model_version'] as String? ?? '1.0',
    promptVersion: json['prompt_version'] as String? ?? '1.0',
    schemaVersion: json['schema_version'] as int? ?? 1,
    confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    rawOutput: json['raw_output'] as String? ?? '',
    validatedOutput: json['validated_output'] as String?,
    isConfirmed: json['is_confirmed'] as bool? ?? false,
    timestamp: json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'] as String)
        : null,
  );
}
