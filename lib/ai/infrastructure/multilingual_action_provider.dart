import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/multilingual_model_identity.dart';
import '../domain/core_action_v5.dart';
import '../domain/multilingual_action_semantics.dart';
import 'structured_generation_service.dart';
import 'think_sanitizer.dart';

class MultilingualActionGenerationResult {
  final CoreV5Envelope? envelope;
  final List<String> errors;

  const MultilingualActionGenerationResult({
    required this.envelope,
    this.errors = const [],
  });

  bool get isValid => envelope != null && errors.isEmpty;
}

/// Guarded bridge for the multilingual action candidate.
///
/// Invalid, incomplete, or ungrounded output is returned as a failure so the
/// caller can ask a clarification or use deterministic parsing. This provider
/// never executes the proposed tool.
class MultilingualActionProvider {
  MultilingualActionProvider._();
  static final instance = MultilingualActionProvider._();

  static const _channel = MethodChannel('noteechoes/mlx_multilingual_action');
  static const _systemPrompt =
      '''You are the private on-device NoteEchoes multilingual semantic parser. Read English, Hindi, Telugu, Romanized speech, and code-switching between them. Return exactly one JSON object matching Action Semantics schema version 1. Copy items, names, dates, times, places, subjects, and dictated drafts from the transcript; never translate or invent them. Choose memory_query for questions about saved notes. Choose clarify when a requested reminder or calendar action lacks essential information, and ask one short question in the user's language. Never claim an action happened.''';

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<bool> isReady() async {
    try {
      final status = await _channel.invokeMapMethod<Object?, Object?>('status');
      return status?['verified'] == true;
    } on Object {
      return false;
    }
  }

  Future<void> load() async {
    await _channel.invokeMethod<bool>('load');
    _isLoaded = true;
  }

  Future<void> unload() async {
    await _channel.invokeMethod<void>('unload');
    _isLoaded = false;
  }

  Future<MultilingualActionGenerationResult> interpret({
    required String transcript,
    String? whisperReportedLanguage,
    String? preferredLanguage,
  }) async {
    try {
      if (!_isLoaded) await load();
      final raw = await _channel.invokeMethod<String>('generate', {
        'systemPrompt': '/no_think\n$_systemPrompt',
        'prompt': transcript,
        'temperature': 0.0,
        'maxTokens': 300,
      });
      final clean = ThinkSanitizer.clean(raw);
      final json = StructuredGenerationService.extractJsonMap(clean);
      if (json == null) {
        return const MultilingualActionGenerationResult(
          envelope: null,
          errors: ['The action model did not return valid JSON.'],
        );
      }
      final semantics = const MultilingualActionSemanticsValidator().parse(
        json,
        rawTranscript: transcript,
      );
      if (!semantics.isValid) {
        return MultilingualActionGenerationResult(
          envelope: null,
          errors: semantics.errors,
        );
      }
      final envelope = const MultilingualActionPolicyEnricher().enrich(
        semantics.value!,
        rawTranscript: transcript,
        whisperReportedLanguage: whisperReportedLanguage,
        preferredLanguage: preferredLanguage,
      );
      return MultilingualActionGenerationResult(envelope: envelope);
    } on Object catch (error) {
      debugPrint('[MultilingualActionProvider] Safe fallback: $error');
      return MultilingualActionGenerationResult(
        envelope: null,
        errors: [error.toString()],
      );
    }
  }

  String get modelId => NoteEchoesMultilingualActionModelIdentity.modelId;
}
