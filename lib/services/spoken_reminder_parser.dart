import '../ai/domain/core_action_v4_adapter.dart';
import '../ai/domain/note_analysis.dart';
import 'voice_note_title_service.dart';

class SpokenReminderParser {
  const SpokenReminderParser._();

  static Reminder? parse(String speech, {DateTime? now}) {
    final compact = speech.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (!_hasReminderIntent(compact)) return null;
    final base = now ?? DateTime.now();
    final trigger = CoreActionV4Adapter.parseSpokenDateTime(compact, base);
    if (trigger == null || !trigger.isAfter(base)) return null;

    return Reminder(
      id: 'spoken-reminder-${base.microsecondsSinceEpoch}',
      title: VoiceNoteTitleService.concise(
        proposedTitle: _actionText(compact),
        spokenText: compact,
      ),
      triggerDate: trigger,
      confidence: 1,
      evidenceText: compact,
    );
  }

  static bool _hasReminderIntent(String value) => RegExp(
    r'\b(?:remind\s+me|set\s+(?:a\s+)?reminder|reminder\s+(?:for|at)|'
    r'gurthu\s+chey|gurtu\s+chey|yaad\s+dila|reminder\s+pettu)\b|'
    r'గుర్తు\s*(?:చేయి|చెయ్యి|చేయాలని)|రిమైండర్|'
    r'याद\s+दिल|रिमाइंडर',
    caseSensitive: false,
  ).hasMatch(value);

  static String _actionText(String value) {
    var result = value.replaceFirst(
      RegExp(
        r'^(?:please\s+)?(?:remind\s+me|set\s+(?:a\s+)?reminder(?:\s+for)?|'
        r'reminder\s+pettu|gurthu\s+chey\w*|gurtu\s+chey\w*|yaad\s+dila\w*|'
        r'రిమైండర్|याद\s+दिला\w*|रिमाइंडर)\s*',
        caseSensitive: false,
      ),
      '',
    );
    result = result.replaceAll(
      RegExp(
        r'\b(?:today|tomorrow|repu|ivala|kal|aaj|next\s+\w+)\b|'
        r'\bin\s+\d{1,3}\s+(?:minutes?|hours?)\b|'
        r'\b(?:at|by)\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)?\b|'
        r'ఈరోజు|రేపు|आज|कल|'
        r'\d{1,2}(?::\d{2})?\s*(?:గంటలకు|గంటకి|बजे)',
        caseSensitive: false,
      ),
      ' ',
    );
    result = result
        .replaceFirst(RegExp(r'^\s*(?:to|that)\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return result.isEmpty ? value : result;
  }
}
