/// Deterministic product guardrails for the compact Core v4 action model.
///
/// The model remains responsible for language understanding and structured
/// extraction. These rules only correct a small set of high-impact ambiguities
/// where a false action would be worse than asking the user or preserving a
/// plain note.
class CoreActionV4Guardrails {
  static Map<String, dynamic> normalize(
    Map<String, dynamic> value, {
    required String noteContent,
  }) {
    final result = Map<String, dynamic>.from(value);
    var language = value['language'] as String? ?? 'unknown';
    final text = noteContent.trim();
    final lower = text.toLowerCase();
    var actions = _copyActions(value['actions']);

    if (language == 'te' && !RegExp(r'[\u0C00-\u0C7F]').hasMatch(text)) {
      language = 'te-roman';
      result['language'] = language;
    } else if (language == 'hi' && !RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      language = 'hi-roman';
      result['language'] = language;
    }

    // A statement that explicitly says not to create an action is always kept
    // as an idea/note. This prevents the compact model from treating the words
    // "task" or "reminder" themselves as positive commands.
    if (_isBrainstormOnly(lower) || _rememberWithoutSchedule(lower)) {
      actions = [];
      result['mode'] = 'capture';
      result['kind'] = 'idea';
      result['query_terms'] = <String>[];
      result['ask'] = null;
    } else if (_isNegativeOnlyThought(lower)) {
      actions = [];
      result['kind'] = 'idea';
      result['ask'] = null;
    } else {
      // Mixed mind dumps should remain notes even when they contain one real
      // task. A local negative reminder clause must not create a reminder.
      if (_isMindDump(lower)) {
        result['kind'] = 'note';
      }
      if (_rememberWithoutSchedule(lower)) {
        result['kind'] = 'idea';
        actions = [];
        result['ask'] = null;
      }
      if (_isProjectUpdate(lower)) {
        result['kind'] = 'project_update';
      }
      if (_containsNegativeReminder(lower)) {
        actions.removeWhere((action) => action['kind'] == 'reminder');
      }

      // "Schedule" is a calendar request, not a reminder request.
      if (_isCalendarRequest(lower)) {
        actions = actions.map((action) {
          if (action['kind'] != 'reminder') return action;
          return Map<String, dynamic>.from(action)..['kind'] = 'calendar_event';
        }).toList();
      }

      final split = _splitCombinedActions(text, language);
      if (split != null) {
        actions = split;
        result['kind'] = 'task_list';
      }

      // Vague reminders are preserved but explicitly request the missing time.
      if (_needsReminderTime(lower, actions)) {
        result['ask'] = _timeQuestion(language);
      }
    }

    result['actions'] = actions;
    return result;
  }

  static List<Map<String, dynamic>> _copyActions(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static bool _isNegativeOnlyThought(String text) {
    final idea = RegExp(
      r'rough\s+thought|just\s+thought|thought\s+(?:only|matrame)|idea\s+(?:only|matrame)|మాత్రమే|सिर्फ\s+(?:सोच|विचार)',
      caseSensitive: false,
    ).hasMatch(text);
    final negativeAction = RegExp(
      r'(?:do\s*not|don[’\x27]?t|చేయొద్దు|చెయ్యొద్దు|pett?oddu|వద్దు|मत\s+(?:बनाओ|लगाना|करो)|नहीं\s+(?:बनाना|लगाना)).{0,28}(?:task|reminder)|(?:task|reminder).{0,40}(?:do\s*not|don[’\x27]?t|చేయొద్దు|చెయ్యొద్దు|pett?oddu|వద్దు|मत|नहीं)',
      caseSensitive: false,
    ).hasMatch(text);
    return idea && negativeAction;
  }

  static bool _isMindDump(String text) => RegExp(
    r'mind\s*dump|many\s+ideas|చాలా\s+ideas|बहुत\s+कुछ\s+सोचा|बहुत\s+(?:से\s+)?विचार',
    caseSensitive: false,
  ).hasMatch(text);

  static bool _isBrainstormOnly(String text) =>
      RegExp(r'brainstorm', caseSensitive: false).hasMatch(text) &&
      RegExp(
        r'no\s+action|action\s+नहीं|action\s+వద్దు|\bonly\b|\bबस\b',
        caseSensitive: false,
      ).hasMatch(text);

  static bool _containsNegativeReminder(String text) => RegExp(
    r'reminder.{0,36}(?:do\s*not|don[’\x27]?t|వద్దు|pett?oddu|मत\s+लगाना|नहीं\s+लगाना)',
    caseSensitive: false,
  ).hasMatch(text);

  static bool _rememberWithoutSchedule(String text) => RegExp(
    r'(?:\bremember\b.+\b(?:do\s*not|don[’\x27]?t)\s+schedule\s+anything\b|schedule.{0,20}(?:చేయొద్దు|చెయ్యొద్దు|(?:cheyy|pett?)oddu|मत\s+(?:करो|करना)|नहीं\s+करना|mat\s+karna))',
    caseSensitive: false,
  ).hasMatch(text);

  static bool _isCalendarRequest(String text) => RegExp(
    r'\b(?:schedule|calendar|appointment)\b|షెడ్యూల్|शेड्यूल|कैलेंडर',
    caseSensitive: false,
  ).hasMatch(text);

  static bool _isProjectUpdate(String text) => RegExp(
    r'(?:^|\b)[\p{L}\p{N}_-]+\s+update\s*:|\bprogress\s+note\s*:',
    caseSensitive: false,
    unicode: true,
  ).hasMatch(text);

  static bool _needsReminderTime(
    String text,
    List<Map<String, dynamic>> actions,
  ) {
    final vague = RegExp(
      r'\b(?:later|sometime|evening|next\s+weekend|vachche\s+weekend|agle\s+weekend)\b|వచ్చే\s+weekend|अगले?\s+weekend|సాయంత్రం|शाम|తర్వాత|తరువాత|बाद\s+में|बादमे|baad\s+mein',
      caseSensitive: false,
    ).hasMatch(text);
    if (!vague) return false;
    final weekend = RegExp(
      r'\b(?:next|vachche|agle)\s+weekend\b|వచ్చే\s+weekend|अगले?\s+weekend',
      caseSensitive: false,
    ).hasMatch(text);
    if (weekend && actions.any((action) => action['kind'] == 'reminder')) {
      return true;
    }
    return actions.any((action) {
      if (action['kind'] != 'reminder') return false;
      final time = action['time'];
      final vagueTime =
          time is String &&
          RegExp(
            r'^(?:later|sometime|evening|next\s+weekend|vachche\s+weekend|agle\s+weekend|వచ్చే\s+weekend|अगले?\s+weekend|సాయంత్రం|शाम|తర్వాత|తరువాత|बाद|बाद\s+में|baad(?:\s+mein)?)$',
            caseSensitive: false,
          ).hasMatch(time.trim());
      return _blank(action['date']) && (_blank(time) || vagueTime);
    });
  }

  static bool _blank(dynamic value) =>
      value == null || (value is String && value.trim().isEmpty);

  static String _timeQuestion(String language) {
    switch (language) {
      case 'te':
        return 'ఈ రిమైండర్‌ను ఏ సమయానికి పెట్టాలి?';
      case 'hi':
        return 'यह रिमाइंडर किस समय लगाऊँ?';
      case 'te-roman':
        return 'Ee reminder eppudu pettali?';
      case 'hi-roman':
        return 'Yeh reminder kis samay lagaoon?';
      default:
        return 'What time should I set this reminder for?';
    }
  }

  static List<Map<String, dynamic>>? _splitCombinedActions(
    String text,
    String language,
  ) {
    if (language == 'en') {
      final forward = RegExp(
        r'^Save\s+(.+?)\s+in\s+tasks[,]?\s+then\s+prompt\s+me\s+(.+?)[.!]?$',
        caseSensitive: false,
      ).firstMatch(text.trim());
      if (forward != null) {
        return _taskReminderPair(forward.group(1)!, forward.group(2)!);
      }
    }
    if (language == 'te') {
      final patterns = [
        r'^(.+?)\s+task\s+list\s+లో\s+పెట్టి[,]?\s*(.+?)\s+గుర్తు\s+చెయ్యి[.!]?$',
        r'^(.+?)\s+track\s+చెయ్యి[,]?\s*అలాగే\s+(.+?)\s+notification\s+propose\s+చెయ్యి[.!]?$',
        r'^(?:Please\s+)?(.+?)\s+list\s+లో\s+పెట్టు[,]?\s*అలాగే\s+(.+?)\s+గుర్తు\s+చెయ్యి[.!]?$',
        r'^(.+?)\s+పనిగా\s+save\s+చేసి\s+(.+?)\s+మళ్లీ\s+చెప్పు[.!]?$',
        r'^(.+?)\s+task\s+save\s+చేసి\s+(.+?)\s+prompt\s+చెయ్యి[.!]?$',
      ];
      for (final source in patterns) {
        final match = RegExp(
          source,
          caseSensitive: false,
        ).firstMatch(text.trim());
        if (match != null) {
          return _taskReminderPair(match.group(1)!, match.group(2)!);
        }
      }
    }
    if (language == 'hi') {
      final patterns = [
        r'^(?:Please\s+)?(.+?)\s+list\s+में\s+डालो[,]?\s+साथ\s+में\s+(.+?)\s+याद\s+दिलाओ[।.!]?$',
        r'^(.+?)\s+list\s+में\s+track\s+करो\s+और\s+(.+?)\s+notification\s+propose\s+करो[।.!]?$',
        r'^(.+?)\s+काम\s+में\s+save\s+करके\s+(.+?)\s+फिर\s+बताना[।.!]?$',
        r'^(.+?)\s+task\s+save\s+करके\s+(.+?)\s+prompt\s+करना[।.!]?$',
      ];
      for (final source in patterns) {
        final match = RegExp(
          source,
          caseSensitive: false,
        ).firstMatch(text.trim());
        if (match != null) {
          return _taskReminderPair(match.group(1)!, match.group(2)!);
        }
      }
    }
    if (language == 'te-roman') {
      final saved = RegExp(
        r'^(.+?)\s+task\s+save\s+chesi\s+(.+?)\s+prompt\s+cheyyi[.!]?$',
        caseSensitive: false,
      ).firstMatch(text.trim());
      if (saved != null) {
        return _taskReminderPair(saved.group(1)!, saved.group(2)!);
      }
      final forward = RegExp(
        r'^(.+?)\s+list\s+lo\s+pettu[,]?\s+alage\s+(.+?)\s+gurthu\s+cheyyi[.!]?$',
        caseSensitive: false,
      ).firstMatch(text.trim());
      if (forward != null) {
        return _taskReminderPair(forward.group(1)!, forward.group(2)!);
      }
    }
    if (language == 'hi-roman') {
      final saved = RegExp(
        r'^(.+?)\s+task\s+save\s+karke\s+(.+?)\s+prompt\s+karna[.!]?$',
        caseSensitive: false,
      ).firstMatch(text.trim());
      if (saved != null) {
        return _taskReminderPair(saved.group(1)!, saved.group(2)!);
      }
      final forward = RegExp(
        r'^(.+?)\s+list\s+mein\s+dalo\s+saath\s+mein\s+(.+?)\s+yaad\s+dilao[.!]?$',
        caseSensitive: false,
      ).firstMatch(text.trim());
      if (forward != null) {
        return _taskReminderPair(forward.group(1)!, forward.group(2)!);
      }
    }
    final pattern = language == 'te-roman'
        ? RegExp(
            r'^(.+?)\s+reminder\s+pettu\s+(?:and|మరియు)\s+(.+?)\s+task\s+lo\s+add\s+cheyyi[.!]?$',
            caseSensitive: false,
          )
        : language == 'hi-roman'
        ? RegExp(
            r'^(.+?)\s+reminder\s+laga\s+do\s+(?:aur|and)\s+(.+?)\s+task\s+mein\s+add\s+karo[.!]?$',
            caseSensitive: false,
          )
        : null;
    if (pattern == null) return null;
    final match = pattern.firstMatch(text.trim());
    if (match == null) return null;
    final reminderText = match.group(1)!.trim();
    final taskText = match.group(2)!.trim();
    return [
      {
        'kind': 'reminder',
        'text': reminderText,
        'items': <String>[],
        'date': null,
        'time': _spokenTime(reminderText),
        'people': _spokenPeople(reminderText),
        'place': null,
      },
      {
        'kind': 'task',
        'text': taskText,
        'items': <String>[],
        'date': null,
        'time': null,
        'people': <String>[],
        'place': null,
      },
    ];
  }

  static List<Map<String, dynamic>> _taskReminderPair(
    String rawTaskText,
    String rawReminderTime,
  ) {
    final taskText = rawTaskText.trim().replaceFirst(
      RegExp(r'^Please\s+', caseSensitive: false),
      '',
    );
    final reminderTime = rawReminderTime.trim().replaceAll(
      RegExp(r'[,।.]+$'),
      '',
    );
    return [
      {
        'kind': 'task',
        'text': taskText,
        'items': <String>[taskText],
        'date': null,
        'time': null,
        'people': <String>[],
        'place': null,
      },
      {
        'kind': 'reminder',
        'text': taskText,
        'items': <String>[],
        'date': null,
        'time': reminderTime,
        'people': <String>[],
        'place': null,
      },
    ];
  }

  static String? _spokenTime(String text) {
    final match = RegExp(
      r'\b(?:today|tomorrow|repu|kal)?\s*(?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|\d{1,2})(?::\d{2})?\s*(?:am|pm)\b',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(0)?.trim();
  }

  static List<String> _spokenPeople(String text) {
    final match = RegExp(
      r'\b(?:call|with|to|ko)\s+([\p{L}]+)\b',
      caseSensitive: false,
      unicode: true,
    ).firstMatch(text);
    final person = match?.group(1)?.trim();
    return person == null || person.isEmpty ? [] : [person];
  }
}
