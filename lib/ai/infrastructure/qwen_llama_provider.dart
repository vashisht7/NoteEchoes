// qwen_llama_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../providers/text_generation_provider.dart';
import '../domain/ai_models.dart';
// Use an alias to avoid name clash with the legacy engine's NoteAnalysisResult.
import '../domain/note_analysis.dart' as domain;
import '../infrastructure/prompt_repository.dart';
import '../../services/ai_categorization_engine.dart' as legacy;

/// Native MLX-backed multilingual text generation provider for iOS.
class QwenLlamaProvider implements TextGenerationProvider {
  QwenLlamaProvider._() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }
  static final QwenLlamaProvider instance = QwenLlamaProvider._();

  bool _isLoaded = false;
  static const _channel = MethodChannel('noteechoes/mlx_text_generation');
  final _progressController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get progressStream => _progressController.stream;

  Future<void> _handleNativeCall(MethodCall call) async {
    if (call.method == 'onMLXDownloadProgress') {
      if (call.arguments is Map) {
        _progressController.add(Map<String, dynamic>.from(call.arguments as Map));
      }
    }
  }

  @override
  String get displayName => 'Qwen3-0.6B MLX 4-bit';

  @override
  String get modelVersion => 'qwen3-0.6b-mlx-4bit';

  @override
  bool get isLoaded => _isLoaded;

  @override
  bool get supportsStreaming => false;

  @override
  Future<void> load() async {
    try {
      await _channel.invokeMethod<bool>('load');
      _isLoaded = true;
    } on PlatformException catch (error) {
      throw GenerationException(
        GenerationErrorCode.modelNotLoaded,
        error.message ?? 'The MLX model could not be loaded.',
      );
    }
  }

  @override
  Future<void> unload() async {
    await _channel.invokeMethod<void>('unload');
    _isLoaded = false;
  }

  @override
  Future<String> generate(
    List<AiMessage> messages, {
    GenerationOptions options = const GenerationOptions(),
    void Function(String token)? onToken,
  }) async {
    if (!_isLoaded) {
      throw GenerationException(
        GenerationErrorCode.modelNotLoaded,
        'Call load() before generate().',
      );
    }
    final systemPrompt = messages
        .where((message) => message.role == AiRole.system)
        .map((message) => message.content)
        .join('\n\n');
    final prompt = messages
        .where((message) => message.role != AiRole.system)
        .map(
          (message) => '${message.role.name.toUpperCase()}: ${message.content}',
        )
        .join('\n\n');
    try {
      final response = await _channel.invokeMethod<String>('generate', {
        'systemPrompt': systemPrompt,
        'prompt': prompt,
        'maxTokens': options.maxTokens,
        'temperature': options.temperature,
      });
      final text = response?.trim() ?? '';
      if (text.isEmpty) {
        throw const GenerationException(
          GenerationErrorCode.unknown,
          'The MLX model returned an empty response.',
        );
      }
      onToken?.call(text);
      return text;
    } on PlatformException catch (error) {
      throw GenerationException(
        GenerationErrorCode.unknown,
        error.message ?? 'Local generation failed.',
      );
    }
  }

  @override
  Future<domain.NoteAnalysisResult> generateNoteAnalysis(
    String noteContent, {
    required String noteId,
    required DateTime noteCreatedAt,
    String? existingTranscript,
  }) async {
    if (!_isLoaded) {
      // ── Fallback: use existing lightweight AiCategorizationEngine ──────
      debugPrint('QwenLlamaProvider: falling back to AiCategorizationEngine');
      final engine = legacy.AiCategorizationEngine();
      final legacyResult = engine.analyzeNote(noteContent);

      return domain.NoteAnalysisResult(
        noteId: noteId,
        modelVersion: 'fallback-categorization-engine',
        detectedLanguage: 'en',
        noteType: _legacyNoteType(legacyResult.categories),
        generatedTitle: legacyResult.title,
        summary: legacyResult.summarySnippet,
        englishRetrievalSummary: legacyResult.summarySnippet,
        topics: legacyResult.categories,
        people: const [],
        places: const [],
        suggestedTags: legacyResult.categories,
        actionItems: legacyResult.extractedChecklist
            .map(
              (c) => domain.ActionItem(
                id: c.id,
                task: c.text,
                confidence: 0.6,
                evidenceText: c.text,
              ),
            )
            .toList(),
        events: const [],
        reminders: const [],
        travelDetails: const [],
        analysedAt: DateTime.now(),
      );
    }

    // ── Full multilingual MLX path ────────────────────────────────────────
    final messages = PromptRepository.instance.noteAnalysisPrompt(
      noteContent: noteContent,
      noteId: noteId,
      noteCreatedAtIso8601: noteCreatedAt.toIso8601String(),
      existingTranscript: existingTranscript,
    );

    final response = await generate(
      messages,
      options: GenerationOptions.structured,
    );
    final start = response.indexOf('{');
    final end = response.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw const GenerationException(
        GenerationErrorCode.invalidSchema,
        'The model did not return a JSON object.',
      );
    }
    try {
      final json =
          jsonDecode(response.substring(start, end + 1))
              as Map<String, dynamic>;
      json['note_id'] = noteId;
      json['model_version'] = modelVersion;
      json['analysed_at'] = DateTime.now().toIso8601String();
      return domain.NoteAnalysisResult.fromJson(json);
    } catch (error) {
      throw GenerationException(
        GenerationErrorCode.invalidSchema,
        'Could not parse local analysis: $error',
      );
    }
  }

  domain.NoteType _legacyNoteType(List<String> categories) {
    if (categories.contains('meeting')) return domain.NoteType.meeting;
    if (categories.contains('tasks')) return domain.NoteType.actionList;
    if (categories.contains('ideas')) return domain.NoteType.brainstorm;
    if (categories.contains('study')) return domain.NoteType.lecture;
    return domain.NoteType.general;
  }
}
