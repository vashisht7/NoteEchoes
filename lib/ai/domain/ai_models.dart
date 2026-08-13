// ai_models.dart
// Shared domain types used across all AI providers and use cases.

/// The language of a recorded or transcribed audio segment.
enum AudioLanguage {
  english,
  telugu,
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
      case AudioLanguage.hindi:
        return 'Hindi';
      case AudioLanguage.auto:
        return 'Auto-detect';
    }
  }

  static AudioLanguage fromBcp47(String code) {
    switch (code.toLowerCase().split('-').first) {
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

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
      };
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
    temperature: 0.1,
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
