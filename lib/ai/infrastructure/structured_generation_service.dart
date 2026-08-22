// structured_generation_service.dart
// Executes structured prompt generations with Qwen MLX:
// 1. Appends /no_think non-thinking instructions
// 2. Passes output through ThinkSanitizer
// 3. Extracts and schema-validates JSON
// 4. Performs 1 bounded repair attempt on JSON errors
// 5. Fallbacks gracefully if generation fails

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../domain/ai_models.dart';
import 'think_sanitizer.dart';

class StructuredGenerationResult<T> {
  final T? value;
  final bool isSuccess;
  final String rawOutput;
  final String sanitizedOutput;
  final String? errorMessage;
  final AiProvenance provenance;

  const StructuredGenerationResult({
    required this.value,
    required this.isSuccess,
    required this.rawOutput,
    required this.sanitizedOutput,
    this.errorMessage,
    required this.provenance,
  });
}

class StructuredGenerationService {
  static const MethodChannel _mlxChannel = MethodChannel('noteechoes/mlx_text_generation');

  /// Executes a prompt through Qwen MLX with /no_think instruction, sanitizes think tags,
  /// extracts JSON, and validates with parser [fromJson].
  static Future<StructuredGenerationResult<T>> generateStructured<T>({
    required String prompt,
    required String systemPrompt,
    required T Function(Map<String, dynamic> json) fromJson,
    required String modelId,
    required String modelVersion,
    required String promptVersion,
    required int schemaVersion,
    double temperature = 0.1,
    int maxTokens = 1024,
  }) async {
    // 1. Non-thinking instruction
    final nonThinkingSystem = "/no_think\n$systemPrompt\nGenerate JSON only. Do not output reasoning or markdown commentary outside the JSON.";

    String raw = "";
    try {
      final response = await _mlxChannel.invokeMethod<String>('generate', {
        'prompt': prompt,
        'systemPrompt': nonThinkingSystem,
        'temperature': temperature,
        'maxTokens': maxTokens,
      });
      raw = response ?? "";
    } on Exception catch (e) {
      debugPrint("[StructuredGen] Generation channel error: $e");
      return StructuredGenerationResult<T>(
        value: null,
        isSuccess: false,
        rawOutput: raw,
        sanitizedOutput: "",
        errorMessage: e.toString(),
        provenance: AiProvenance(
          modelId: modelId,
          modelVersion: modelVersion,
          promptVersion: promptVersion,
          schemaVersion: schemaVersion,
          confidence: 0.0,
          rawOutput: raw,
          validatedOutput: null,
          isConfirmed: false,
        ),
      );
    }

    // 2. Sanitize think tags
    final sanitized = ThinkSanitizer.sanitize(raw);
    var cleanText = sanitized.cleanedText;

    // If think-only output was returned, retry once in strict non-thinking mode
    if (sanitized.isThinkOnly || cleanText.isEmpty) {
      debugPrint("[StructuredGen] Think-only output detected. Retrying once strictly...");
      try {
        final retryResponse = await _mlxChannel.invokeMethod<String>('generate', {
          'prompt': prompt,
          'systemPrompt': "$nonThinkingSystem\nIMPORTANT: Output immediate valid JSON now.",
          'temperature': 0.0,
          'maxTokens': maxTokens,
        });
        raw = retryResponse ?? "";
        cleanText = ThinkSanitizer.clean(raw);
      } catch (_) {}
    }

    // 3. Extract JSON map
    Map<String, dynamic>? parsedJson = extractJsonMap(cleanText);

    // 4. Bounded 1-time repair attempt if invalid
    if (parsedJson == null && cleanText.isNotEmpty) {
      debugPrint("[StructuredGen] Malformed JSON. Attempting bounded 1-shot repair...");
      try {
        final repairPrompt = "Fix this invalid JSON and output ONLY the valid JSON object:\n\n$cleanText";
        final repairResponse = await _mlxChannel.invokeMethod<String>('generate', {
          'prompt': repairPrompt,
          'systemPrompt': "/no_think\nOutput raw valid JSON only.",
          'temperature': 0.0,
          'maxTokens': maxTokens,
        });
        final repairedClean = ThinkSanitizer.clean(repairResponse);
        parsedJson = extractJsonMap(repairedClean);
      } catch (repairError) {
        debugPrint("[StructuredGen] JSON repair attempt failed: $repairError");
      }
    }

    if (parsedJson != null) {
      try {
        final parsedValue = fromJson(parsedJson);
        return StructuredGenerationResult<T>(
          value: parsedValue,
          isSuccess: true,
          rawOutput: raw,
          sanitizedOutput: cleanText,
          provenance: AiProvenance(
            modelId: modelId,
            modelVersion: modelVersion,
            promptVersion: promptVersion,
            schemaVersion: schemaVersion,
            confidence: 0.90,
            rawOutput: raw,
            validatedOutput: jsonEncode(parsedJson),
            isConfirmed: false,
          ),
        );
      } catch (validationError) {
        debugPrint("[StructuredGen] Schema validation failed: $validationError");
      }
    }

    return StructuredGenerationResult<T>(
      value: null,
      isSuccess: false,
      rawOutput: raw,
      sanitizedOutput: cleanText,
      errorMessage: "Could not parse valid JSON matching schema",
      provenance: AiProvenance(
        modelId: modelId,
        modelVersion: modelVersion,
        promptVersion: promptVersion,
        schemaVersion: schemaVersion,
        confidence: 0.0,
        rawOutput: raw,
        validatedOutput: null,
        isConfirmed: false,
      ),
    );
  }

  /// Extracts the first JSON object `{ ... }` from text.
  static Map<String, dynamic>? extractJsonMap(String text) {
    if (text.isEmpty) return null;
    
    // Check if directly valid JSON
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}

    // Check fenced code block ```json ... ```
    final fenceMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```', caseSensitive: false).firstMatch(text);
    if (fenceMatch != null) {
      final inner = fenceMatch.group(1)?.trim();
      if (inner != null && inner.isNotEmpty) {
        try {
          final decoded = jsonDecode(inner);
          if (decoded is Map<String, dynamic>) return decoded;
        } catch (_) {}
      }
    }

    // Find outer curly braces
    final startIdx = text.indexOf('{');
    final endIdx = text.lastIndexOf('}');
    if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
      final candidate = text.substring(startIdx, endIdx + 1);
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }

    return null;
  }
}
