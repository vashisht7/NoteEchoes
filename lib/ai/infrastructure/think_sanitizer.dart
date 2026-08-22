// think_sanitizer.dart
// Strips thinking tags and hidden chain-of-thought tokens from model outputs.
// Guarantee: zero visible or spoken <think> tokens reach the user or storage.

class ThinkSanitizerResult {
  final String cleanedText;
  final bool hadThinkTags;
  final bool isThinkOnly;

  const ThinkSanitizerResult({
    required this.cleanedText,
    required this.hadThinkTags,
    required this.isThinkOnly,
  });
}

class ThinkSanitizer {
  static int _leakageCounter = 0;
  static int get leakageCounter => _leakageCounter;

  /// Resets telemetry counter (useful in tests).
  static void resetTelemetry() {
    _leakageCounter = 0;
  }

  /// Sanitizes raw model output text:
  /// 1. Removes complete `<think>...</think>` blocks (single or multiline).
  /// 2. Removes unclosed `<think>...` blocks if model stream was cut off.
  /// 3. Removes orphan `</think>` tags or stray bracket variations.
  /// 4. Preserves only content after closing think tags.
  /// 5. Detects if the entire generation consisted only of thinking tokens.
  static ThinkSanitizerResult sanitize(String? rawOutput) {
    if (rawOutput == null || rawOutput.trim().isEmpty) {
      return const ThinkSanitizerResult(
        cleanedText: '',
        hadThinkTags: false,
        isThinkOnly: false,
      );
    }

    var text = rawOutput;
    var hadTags = false;

    // Pattern 1: Complete <think>...</think> blocks (case-insensitive, multiline, dotAll)
    final completeThinkRegex = RegExp(
      r'<\s*think\b[^>]*>[\s\S]*?<\s*/\s*think\s*>',
      caseSensitive: false,
    );

    if (completeThinkRegex.hasMatch(text)) {
      hadTags = true;
      _leakageCounter++;
      text = text.replaceAll(completeThinkRegex, '');
    }

    // Pattern 2: Leftover unclosed <think>... until end of string
    final unclosedThinkRegex = RegExp(
      r'<\s*think\b[^>]*>[\s\S]*$',
      caseSensitive: false,
    );
    if (unclosedThinkRegex.hasMatch(text)) {
      hadTags = true;
      _leakageCounter++;
      text = text.replaceAll(unclosedThinkRegex, '');
    }

    // Pattern 3: Orphan closing </think> tags
    final orphanCloseRegex = RegExp(
      r'<\s*/\s*think\s*>',
      caseSensitive: false,
    );
    if (orphanCloseRegex.hasMatch(text)) {
      hadTags = true;
      _leakageCounter++;
      text = text.replaceAll(orphanCloseRegex, '');
    }

    // Pattern 4: Strip /no_think command echo if the model echoed it back
    text = text.replaceAll(RegExp(r'^/no_think\s*', caseSensitive: false), '');

    final trimmed = text.trim();
    final isThinkOnly = hadTags && trimmed.isEmpty;

    return ThinkSanitizerResult(
      cleanedText: trimmed,
      hadThinkTags: hadTags,
      isThinkOnly: isThinkOnly,
    );
  }

  /// Helper to get clean string directly
  static String clean(String? rawOutput) => sanitize(rawOutput).cleanedText;
}
