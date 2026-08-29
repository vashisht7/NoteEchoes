import '../infrastructure/language_detection_service.dart';
import 'core_action_v5.dart';

/// Minimal learned output for the multilingual action model.
///
/// Language, mode, provider, confirmation, and confidence are deliberately
/// absent. They are deterministic application policy and are added only after
/// this meaning object passes exact-key and grounding validation.
class MultilingualActionSemantics {
  static const rootKeys = <String>{
    'schema_version',
    'intent',
    'title',
    'items',
    'recipient',
    'people',
    'date',
    'time',
    'place',
    'subject',
    'draft',
    'clarification_question',
  };

  final String intent;
  final String? title;
  final List<String> items;
  final String? recipient;
  final List<String> people;
  final String? date;
  final String? time;
  final String? place;
  final String? subject;
  final String? draft;
  final String? clarificationQuestion;

  const MultilingualActionSemantics({
    required this.intent,
    required this.title,
    required this.items,
    required this.recipient,
    required this.people,
    required this.date,
    required this.time,
    required this.place,
    required this.subject,
    required this.draft,
    required this.clarificationQuestion,
  });
}

class MultilingualSemanticsResult {
  final MultilingualActionSemantics? value;
  final List<String> errors;

  const MultilingualSemanticsResult(this.value, this.errors);

  bool get isValid => value != null && errors.isEmpty;
}

class MultilingualActionSemanticsValidator {
  static const supportedIntents = <String>{
    'note',
    'checklist',
    'task',
    'reminder',
    'calendar',
    'message',
    'email',
    'memory_query',
    'cancel',
    'clarify',
    'noop',
  };

  const MultilingualActionSemanticsValidator();

  MultilingualSemanticsResult parse(
    Map<String, dynamic> json, {
    required String rawTranscript,
  }) {
    final errors = <String>[];
    final keys = json.keys.toSet();
    if (keys.length != MultilingualActionSemantics.rootKeys.length ||
        !keys.containsAll(MultilingualActionSemantics.rootKeys)) {
      errors.add(r'$ must contain exactly the Action Semantics keys');
    }
    if (json['schema_version'] != 1) {
      errors.add(r'$.schema_version must equal 1');
    }
    final intent = json['intent'];
    if (intent is! String || !supportedIntents.contains(intent)) {
      errors.add(r'$.intent is unsupported');
    }
    final title = _nullableString(json['title'], 'title', 96, errors);
    final recipient = _nullableString(
      json['recipient'],
      'recipient',
      160,
      errors,
    );
    final date = _nullableString(json['date'], 'date', 160, errors);
    final time = _nullableString(json['time'], 'time', 160, errors);
    final place = _nullableString(json['place'], 'place', 240, errors);
    final subject = _nullableString(json['subject'], 'subject', 240, errors);
    final draft = _nullableString(json['draft'], 'draft', 4000, errors);
    final clarification = _nullableString(
      json['clarification_question'],
      'clarification_question',
      400,
      errors,
    );
    final items = _stringList(json['items'], 'items', 25, 500, errors);
    final people = _stringList(json['people'], 'people', 12, 160, errors);
    if (intent == 'clarify' && clarification == null) {
      errors.add(r'$.clarification_question is required for clarify');
    }
    if ({'cancel', 'noop'}.contains(intent) &&
        (items.isNotEmpty ||
            people.isNotEmpty ||
            [
              recipient,
              date,
              time,
              place,
              subject,
              draft,
              clarification,
            ].any((value) => value != null))) {
      errors.add(r'cancel/noop may not contain action fields');
    }
    // Fail closed on incomplete external-action proposals. A model may
    // classify the request correctly while dropping one critical span; that
    // must become a clarification, never an assumed value.
    if (intent == 'reminder' &&
        (items.isEmpty || date == null || time == null)) {
      errors.add('reminder requires an item, date, and time');
    }
    if (intent == 'calendar' &&
        (title == null || date == null || time == null)) {
      errors.add('calendar requires a title, date, and time');
    }
    if (intent == 'task' && items.isEmpty) {
      errors.add('task requires at least one grounded item');
    }
    if (intent == 'checklist' && items.isEmpty) {
      errors.add('checklist requires at least one grounded item');
    }
    if (intent == 'message' && (recipient == null || draft == null)) {
      errors.add('message requires a recipient and draft');
    }
    if (intent == 'email' &&
        (recipient == null || subject == null || draft == null)) {
      errors.add('email requires a recipient, subject, and draft');
    }
    for (final value in <String?>[
      recipient,
      date,
      time,
      place,
      subject,
      draft,
      ...items,
      ...people,
    ]) {
      if (value != null && !_grounded(value, rawTranscript)) {
        errors.add('Ungrounded value: $value');
      }
    }
    if (errors.isNotEmpty || intent is! String) {
      return MultilingualSemanticsResult(null, errors);
    }
    return MultilingualSemanticsResult(
      MultilingualActionSemantics(
        intent: intent,
        title: title,
        items: items,
        recipient: recipient,
        people: people,
        date: date,
        time: time,
        place: place,
        subject: subject,
        draft: draft,
        clarificationQuestion: clarification,
      ),
      const [],
    );
  }

  static String? _nullableString(
    dynamic value,
    String field,
    int maximum,
    List<String> errors,
  ) {
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty || value.length > maximum) {
      errors.add(
        r'$.'
        '$field must be null or a bounded non-empty string',
      );
      return null;
    }
    return value.trim();
  }

  static List<String> _stringList(
    dynamic value,
    String field,
    int maximumItems,
    int maximumLength,
    List<String> errors,
  ) {
    if (value is! List || value.length > maximumItems) {
      errors.add(
        r'$.'
        '$field must be a bounded string array',
      );
      return const [];
    }
    final result = <String>[];
    for (final item in value) {
      if (item is! String ||
          item.trim().isEmpty ||
          item.length > maximumLength) {
        errors.add(
          r'$.'
          '$field contains an invalid string',
        );
      } else {
        result.add(item.trim());
      }
    }
    return result;
  }

  static bool _grounded(String value, String rawTranscript) {
    String normalize(String input) => input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final needle = normalize(value);
    return needle.isNotEmpty && normalize(rawTranscript).contains(needle);
  }
}

class MultilingualActionPolicyEnricher {
  const MultilingualActionPolicyEnricher();

  CoreV5Envelope enrich(
    MultilingualActionSemantics semantics, {
    required String rawTranscript,
    String? whisperReportedLanguage,
    String? preferredLanguage,
  }) {
    final detection = LanguageDetectionService.detect(
      rawTranscript,
      whisperReportedLang: whisperReportedLanguage,
      userPreferredLang: preferredLanguage,
    );
    final language = switch (detection.primaryLanguage) {
      'te' when detection.isRomanized => 'te-roman',
      'hi' when detection.isRomanized => 'hi-roman',
      final value when coreV5Languages.contains(value) => value,
      _ => 'unknown',
    };
    final intent = semantics.intent;
    final mode = intent == 'memory_query'
        ? 'query'
        : {'cancel', 'clarify', 'noop'}.contains(intent)
        ? 'control'
        : 'capture';
    final tool = coreV5ToolForIntent[intent];
    final requiresConfirmation = {
      'reminder',
      'calendar',
      'message',
      'email',
      'clarify',
    }.contains(intent);
    final normalizedText = rawTranscript.trim();
    return CoreV5Envelope(
      schemaVersion: 5,
      language: language,
      mode: mode,
      normalizedText: normalizedText,
      intent: intent,
      title: semantics.title,
      items: semantics.items.map(CoreV5Item.new).toList(growable: false),
      entities: CoreV5Entities(
        recipientQuery: semantics.recipient,
        datePhrase: semantics.date,
        timePhrase: semantics.time,
        people: semantics.people,
        place: semantics.place,
        subject: semantics.subject,
      ),
      draft: semantics.draft,
      proposedTool: CoreV5ToolProposal(
        name: tool,
        arguments: tool == null
            ? const {}
            : <String, dynamic>{'normalized_text': normalizedText},
      ),
      // This is a post-validation operational score, not self-reported model
      // probability. Model confidence is intentionally excluded from training.
      confidence: 0.85,
      requiresConfirmation: requiresConfirmation,
      clarificationQuestion: semantics.clarificationQuestion,
    );
  }
}
