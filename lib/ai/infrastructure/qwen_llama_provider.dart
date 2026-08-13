// qwen_llama_provider.dart
// Stub implementation of TextGenerationProvider for Qwen3.5-0.8B.
//
// TODO: Real integration steps once llamadart is available:
//   1. flutter pub add llamadart
//   2. Replace the _isLoaded = true with: _model = await Llama.load(modelPath)
//   3. Replace the generate() stub with: return await _model.generate(messages)
//   4. Use the returned JSON for structured NoteAnalysisResult parsing.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../providers/text_generation_provider.dart';
import '../domain/ai_models.dart';
// Use an alias to avoid name clash with the legacy engine's NoteAnalysisResult.
import '../domain/note_analysis.dart' as domain;
import '../config/ai_feature_flags.dart';
import '../infrastructure/prompt_repository.dart';
import '../../services/ai_categorization_engine.dart' as legacy;

/// Stub Qwen3.5-0.8B text generation provider.
/// Falls back to the existing [AiCategorizationEngine] for note analysis
/// until the LLM is installed and loaded.
class QwenLlamaProvider implements TextGenerationProvider {
  QwenLlamaProvider._();
  static final QwenLlamaProvider instance = QwenLlamaProvider._();

  bool _isLoaded = false;

  @override
  String get displayName => 'Qwen 3.5-0.8B Q4_K_M';

  @override
  String get modelVersion => '3.5-0.8b-q4km-v1';

  @override
  bool get isLoaded => _isLoaded;

  @override
  bool get supportsStreaming => false;

  @override
  Future<void> load() async {
    if (!AiFeatureFlags.instance.localLlmEnabled) {
      throw GenerationException(
        GenerationErrorCode.modelNotLoaded,
        'LLM disabled or model not installed. '
        'Download it from Settings → AI Models.',
      );
    }
    // TODO(llamadart): _model = await Llama.load(modelPath, threads: inferenceThreads);
    _isLoaded = true;
    debugPrint('QwenLlamaProvider: stub loaded (no real model yet)');
  }

  @override
  Future<void> unload() async {
    // TODO(llamadart): await _model?.dispose();
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
    // TODO(llamadart): return await _model.generate(messages, options: options);
    await Future.delayed(const Duration(milliseconds: 200));
    return '[LLM stub: model not yet integrated. Install from Settings → AI Models]';
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
            .map((c) => domain.ActionItem(
                  id: c.id,
                  task: c.text,
                  confidence: 0.6,
                  evidenceText: c.text,
                ))
            .toList(),
        events: const [],
        reminders: const [],
        travelDetails: const [],
        analysedAt: DateTime.now(),
      );
    }

    // ── Full LLM path (stub until llamadart integration) ──────────────────
    final messages = PromptRepository.instance.noteAnalysisPrompt(
      noteContent: noteContent,
      noteId: noteId,
      noteCreatedAtIso8601: noteCreatedAt.toIso8601String(),
      existingTranscript: existingTranscript,
    );

    // TODO(llamadart): parse the real LLM JSON output here.
    await generate(messages);

    // Placeholder until real LLM generates valid JSON.
    return domain.NoteAnalysisResult(
      noteId: noteId,
      modelVersion: modelVersion,
      detectedLanguage: 'en',
      noteType: domain.NoteType.general,
      generatedTitle: 'Pending LLM Analysis',
      summary: '[Install Qwen model for AI summaries]',
      englishRetrievalSummary: noteContent.substring(
          0, noteContent.length.clamp(0, 200)),
      analysedAt: DateTime.now(),
    );
  }

  domain.NoteType _legacyNoteType(List<String> categories) {
    if (categories.contains('meeting')) return domain.NoteType.meeting;
    if (categories.contains('tasks')) return domain.NoteType.actionList;
    if (categories.contains('ideas')) return domain.NoteType.brainstorm;
    if (categories.contains('study')) return domain.NoteType.lecture;
    return domain.NoteType.general;
  }
}
