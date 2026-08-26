/// Strict domain model and fail-closed validation for NoteEchoes Core v5.
library;

const coreV5Languages = <String>{
  'en',
  'hi',
  'te',
  'hi-roman',
  'te-roman',
  'mixed',
  'unknown',
};

const coreV5Modes = <String>{'capture', 'query', 'control'};

const coreV5Intents = <String>{
  'note',
  'checklist',
  'task',
  'reminder',
  'calendar',
  'message',
  'email',
  'prompt',
  'idea',
  'decision',
  'project_update',
  'memory_query',
  'cancel',
  'clarify',
  'noop',
};

const coreV5ToolForIntent = <String, String?>{
  'note': 'notes.create',
  'checklist': 'checklists.create',
  'task': 'tasks.create',
  'reminder': 'reminders.propose',
  'calendar': 'calendar.propose_event',
  'message': 'messages.compose',
  'email': 'email.compose',
  'prompt': 'prompts.save',
  'idea': 'notes.create',
  'decision': 'notes.create',
  'project_update': 'notes.create',
  'memory_query': 'memory.search',
  'cancel': null,
  'clarify': null,
  'noop': null,
};

class CoreV5Item {
  final String text;

  const CoreV5Item(this.text);
}

class CoreV5Entities {
  final String? recipientQuery;
  final String? datePhrase;
  final String? timePhrase;
  final List<String> people;
  final String? place;
  final String? subject;

  const CoreV5Entities({
    this.recipientQuery,
    this.datePhrase,
    this.timePhrase,
    this.people = const [],
    this.place,
    this.subject,
  });
}

class CoreV5ToolProposal {
  final String? name;
  final Map<String, dynamic> arguments;

  const CoreV5ToolProposal({required this.name, required this.arguments});
}

class CoreV5Envelope {
  final int schemaVersion;
  final String language;
  final String mode;
  final String normalizedText;
  final String intent;
  final String? title;
  final List<CoreV5Item> items;
  final CoreV5Entities entities;
  final String? draft;
  final CoreV5ToolProposal proposedTool;
  final double confidence;
  final bool requiresConfirmation;
  final String? clarificationQuestion;

  const CoreV5Envelope({
    required this.schemaVersion,
    required this.language,
    required this.mode,
    required this.normalizedText,
    required this.intent,
    required this.title,
    required this.items,
    required this.entities,
    required this.draft,
    required this.proposedTool,
    required this.confidence,
    required this.requiresConfirmation,
    required this.clarificationQuestion,
  });
}

class CoreV5ValidationResult {
  final CoreV5Envelope? value;
  final List<String> errors;

  const CoreV5ValidationResult._(this.value, this.errors);

  bool get isValid => value != null && errors.isEmpty;
}

class CoreV5Validator {
  static const _rootKeys = <String>{
    'schema_version',
    'language',
    'mode',
    'normalized_text',
    'intent',
    'title',
    'items',
    'entities',
    'draft',
    'proposed_tool',
    'confidence',
    'requires_confirmation',
    'clarification_question',
  };
  static const _entityKeys = <String>{
    'recipient_query',
    'date_phrase',
    'time_phrase',
    'people',
    'place',
    'subject',
  };
  static const _toolKeys = <String>{'name', 'arguments'};

  const CoreV5Validator();

  CoreV5ValidationResult parseAndValidate(
    Map<String, dynamic> json, {
    required String rawTranscript,
  }) {
    final errors = <String>[];
    _exactKeys(json, _rootKeys, r'$', errors);
    final entitiesJson = _map(json['entities'], r'$.entities', errors);
    final toolJson = _map(json['proposed_tool'], r'$.proposed_tool', errors);
    _exactKeys(entitiesJson, _entityKeys, r'$.entities', errors);
    _exactKeys(toolJson, _toolKeys, r'$.proposed_tool', errors);

    final version = json['schema_version'];
    if (version != 5) errors.add(r'$.schema_version must equal 5');
    final language = _string(json['language'], r'$.language', errors);
    if (!coreV5Languages.contains(language)) {
      errors.add(r'$.language is unsupported');
    }
    final mode = _string(json['mode'], r'$.mode', errors);
    if (!coreV5Modes.contains(mode)) errors.add(r'$.mode is unsupported');
    final normalizedText = _boundedString(
      json['normalized_text'],
      r'$.normalized_text',
      8000,
      errors,
    );
    final intent = _string(json['intent'], r'$.intent', errors);
    if (!coreV5Intents.contains(intent)) errors.add(r'$.intent is unsupported');
    final title = _nullableBoundedString(json['title'], r'$.title', 96, errors);
    final draft = _nullableBoundedString(
      json['draft'],
      r'$.draft',
      8000,
      errors,
    );
    final clarification = _nullableBoundedString(
      json['clarification_question'],
      r'$.clarification_question',
      500,
      errors,
    );

    final items = <CoreV5Item>[];
    final itemsJson = json['items'];
    if (itemsJson is! List || itemsJson.length > 50) {
      errors.add(r'$.items must be an array with at most 50 entries');
    } else {
      for (var i = 0; i < itemsJson.length; i++) {
        final item = _map(itemsJson[i], r'$.items[]', errors);
        _exactKeys(item, const {'text'}, r'$.items[]', errors);
        final text = _boundedString(
          item['text'],
          r'$.items[].text',
          1000,
          errors,
        );
        if (text.isNotEmpty) {
          items.add(CoreV5Item(text));
          if (!_isGrounded(text, rawTranscript)) {
            errors.add(r'$.items[].text is not grounded in the transcript');
          }
        }
      }
    }

    final people = _strings(
      entitiesJson['people'],
      r'$.entities.people',
      25,
      errors,
    );
    final recipient = _nullableBoundedString(
      entitiesJson['recipient_query'],
      r'$.entities.recipient_query',
      320,
      errors,
    );
    final date = _nullableBoundedString(
      entitiesJson['date_phrase'],
      r'$.entities.date_phrase',
      320,
      errors,
    );
    final time = _nullableBoundedString(
      entitiesJson['time_phrase'],
      r'$.entities.time_phrase',
      320,
      errors,
    );
    final place = _nullableBoundedString(
      entitiesJson['place'],
      r'$.entities.place',
      320,
      errors,
    );
    final subject = _nullableBoundedString(
      entitiesJson['subject'],
      r'$.entities.subject',
      320,
      errors,
    );
    for (final pair in <(String, String?)>[
      (r'$.entities.recipient_query', recipient),
      (r'$.entities.date_phrase', date),
      (r'$.entities.time_phrase', time),
      (r'$.entities.place', place),
      ...people.map((value) => (r'$.entities.people[]', value)),
    ]) {
      if (pair.$2 != null && !_isGrounded(pair.$2!, rawTranscript)) {
        errors.add('${pair.$1} is not grounded in the transcript');
      }
    }

    final toolNameValue = toolJson['name'];
    final toolName = toolNameValue == null
        ? null
        : _string(toolNameValue, r'$.proposed_tool.name', errors);
    final arguments = _map(
      toolJson['arguments'],
      r'$.proposed_tool.arguments',
      errors,
    );
    final expectedTool = coreV5ToolForIntent[intent];
    if (coreV5ToolForIntent.containsKey(intent) && toolName != expectedTool) {
      errors.add(r'$.proposed_tool.name does not match $.intent');
    }

    final confidenceValue = json['confidence'];
    final confidence = confidenceValue is num
        ? confidenceValue.toDouble()
        : -1.0;
    if (confidence < 0 || confidence > 1) {
      errors.add(r'$.confidence must be between 0 and 1');
    }
    final requiresConfirmation = json['requires_confirmation'];
    if (requiresConfirmation is! bool) {
      errors.add(r'$.requires_confirmation must be boolean');
    }
    if ({
          'reminder',
          'calendar',
          'message',
          'email',
          'clarify',
        }.contains(intent) &&
        requiresConfirmation != true) {
      errors.add(r'$.requires_confirmation must be true for this intent');
    }
    if (mode == 'query' && intent != 'memory_query') {
      errors.add(r'query mode requires memory_query intent');
    }
    if (mode == 'control' && !{'cancel', 'clarify', 'noop'}.contains(intent)) {
      errors.add(r'control mode requires cancel, clarify, or noop intent');
    }
    if (intent == 'clarify' && clarification == null) {
      errors.add(r'clarify intent requires a clarification question');
    }

    if (errors.isNotEmpty) {
      return CoreV5ValidationResult._(null, List.unmodifiable(errors));
    }
    return CoreV5ValidationResult._(
      CoreV5Envelope(
        schemaVersion: 5,
        language: language,
        mode: mode,
        normalizedText: normalizedText,
        intent: intent,
        title: title,
        items: List.unmodifiable(items),
        entities: CoreV5Entities(
          recipientQuery: recipient,
          datePhrase: date,
          timePhrase: time,
          people: List.unmodifiable(people),
          place: place,
          subject: subject,
        ),
        draft: draft,
        proposedTool: CoreV5ToolProposal(
          name: toolName,
          arguments: Map.unmodifiable(arguments),
        ),
        confidence: confidence,
        requiresConfirmation: requiresConfirmation as bool,
        clarificationQuestion: clarification,
      ),
      const [],
    );
  }

  static Map<String, dynamic> _map(
    dynamic value,
    String path,
    List<String> errors,
  ) {
    if (value is Map) return Map<String, dynamic>.from(value);
    errors.add('$path must be an object');
    return const {};
  }

  static void _exactKeys(
    Map<String, dynamic> value,
    Set<String> expected,
    String path,
    List<String> errors,
  ) {
    final actual = value.keys.toSet();
    for (final missing in expected.difference(actual)) {
      errors.add('$path is missing $missing');
    }
    for (final extra in actual.difference(expected)) {
      errors.add('$path contains unsupported key $extra');
    }
  }

  static String _string(dynamic value, String path, List<String> errors) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    errors.add('$path must be a non-empty string');
    return '';
  }

  static String _boundedString(
    dynamic value,
    String path,
    int maximum,
    List<String> errors,
  ) {
    final result = _string(value, path, errors);
    if (result.length > maximum) {
      errors.add('$path exceeds $maximum characters');
    }
    return result;
  }

  static String? _nullableBoundedString(
    dynamic value,
    String path,
    int maximum,
    List<String> errors,
  ) {
    if (value == null) return null;
    return _boundedString(value, path, maximum, errors);
  }

  static List<String> _strings(
    dynamic value,
    String path,
    int maximum,
    List<String> errors,
  ) {
    if (value is! List ||
        value.length > maximum ||
        value.any((item) => item is! String || item.trim().isEmpty)) {
      errors.add('$path must contain at most $maximum non-empty strings');
      return const [];
    }
    final result = value.cast<String>().map((item) => item.trim()).toList();
    if (result.toSet().length != result.length) {
      errors.add('$path must not contain duplicates');
    }
    return result;
  }

  static bool _isGrounded(String candidate, String transcript) {
    final normalizedCandidate = _normalize(candidate);
    final normalizedTranscript = _normalize(transcript);
    if (normalizedCandidate.isEmpty) return false;
    if (normalizedTranscript.contains(normalizedCandidate)) return true;
    final candidateTokens = normalizedCandidate.split(' ').toSet();
    final transcriptTokens = normalizedTranscript.split(' ').toSet();
    return candidateTokens.intersection(transcriptTokens).length /
            candidateTokens.length >=
        0.8;
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}
