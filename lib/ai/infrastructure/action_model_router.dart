import 'language_detection_service.dart';

enum ActionModelRoute { english, multilingual }

/// Chooses the action brain from the user's recognition-language setting.
///
/// Explicit English always uses the proven English production model. Explicit
/// Telugu, Hindi, or Telugu-English mixed modes always use the multilingual
/// candidate. Auto mode inspects the actual transcript and keeps English on
/// the proven path.
abstract final class ActionModelRouter {
  static ActionModelRoute route({
    required String recognitionLanguage,
    required String transcript,
    String? whisperReportedLanguage,
  }) {
    if (recognitionLanguage == 'en') return ActionModelRoute.english;
    if (recognitionLanguage != 'auto') {
      return ActionModelRoute.multilingual;
    }
    final detected = LanguageDetectionService.detect(
      transcript,
      whisperReportedLang: whisperReportedLanguage,
    );
    return detected.primaryLanguage == 'en'
        ? ActionModelRoute.english
        : ActionModelRoute.multilingual;
  }
}
