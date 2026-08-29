enum ActionModelRoute { combined }

/// Chooses the production action brain.
///
/// The promoted Qwen3 0.6B Core v5 model was trained on English, Telugu, Hindi,
/// Romanized speech, and code-mixed speech. Every recognition-language setting
/// therefore uses the same downloaded runtime; the setting still controls ASR.
abstract final class ActionModelRouter {
  static ActionModelRoute route({
    required String recognitionLanguage,
    required String transcript,
    String? whisperReportedLanguage,
  }) => ActionModelRoute.combined;
}
