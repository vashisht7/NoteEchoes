import 'note_analysis.dart';

/// Backward-compatible bridge from the focused v4 model contract to the
/// existing NoteEchoes UI/domain objects.
class CoreActionV4Adapter {
  static const _languages = {
    'en',
    'te',
    'hi',
    'te-roman',
    'hi-roman',
    'unknown',
  };

  static NoteAnalysisResult toNoteAnalysis(
    Map<String, dynamic> value, {
    required String noteContent,
    required String noteId,
    required String modelVersion,
    required DateTime analysedAt,
  }) {
    final language = _languages.contains(value['language'])
        ? value['language'] as String
        : 'unknown';
    final mode = value['mode'] == 'query' ? 'query' : 'capture';
    final actions = value['actions'] is List
        ? (value['actions'] as List).whereType<Map>().map(
            (item) => Map<String, dynamic>.from(item),
          )
        : const Iterable<Map<String, dynamic>>.empty();

    final actionItems = <ActionItem>[];
    final events = <CalendarEvent>[];
    final reminders = <Reminder>[];
    final people = <String>{};
    final places = <String>{};

    var sequence = 0;
    for (final action in actions.take(10)) {
      final actionKind = action['kind'] as String?;
      final text = _text(action['text'] ?? action['title']);
      if (text == null) continue;
      final actionPeople = _strings(action['people'], 10);
      people.addAll(actionPeople);
      final place = _text(action['place'] ?? action['location']);
      if (place != null) places.add(place);
      final date = _parseDate(action['date'], action['time'], analysedAt);

      if (actionKind == 'task') {
        final spokenItems = _groundedItems(action['items'], noteContent);
        final tasks = spokenItems.isEmpty ? <String>[text] : spokenItems;
        for (final task in tasks) {
          actionItems.add(
            ActionItem(
              id: '$noteId-task-${sequence++}',
              task: task,
              assignee: actionPeople.isEmpty ? null : actionPeople.first,
              dueDate: date,
              confidence: 1,
              evidenceText: task,
            ),
          );
        }
      } else if (actionKind == 'reminder') {
        reminders.add(
          Reminder(
            id: '$noteId-reminder-${sequence++}',
            title: text,
            triggerDate: date,
            isUncertain: date == null,
            confidence: 1,
            evidenceText: text,
          ),
        );
      } else if (actionKind == 'calendar_event') {
        events.add(
          CalendarEvent(
            id: '$noteId-event-${sequence++}',
            title: text,
            startDate: date,
            isAllDay: _text(action['time']) == null,
            location: place,
            attendees: actionPeople,
            confidence: 1,
            evidenceText: text,
          ),
        );
      }
    }

    final title = mode == 'query'
        ? noteContent.trim()
        : (_text(value['title']) ?? _safeTitle(noteContent));
    final summary = mode == 'query'
        ? noteContent.trim()
        : (_text(value['summary']) ?? noteContent.trim());
    final kind = value['kind'] as String?;

    return NoteAnalysisResult(
      noteId: noteId,
      modelVersion: modelVersion,
      detectedLanguage: language,
      noteType: _noteType(kind, actionItems, events, reminders),
      generatedTitle: title,
      summary: summary,
      englishRetrievalSummary: summary,
      topics: kind == null || kind == 'none' ? const [] : [kind],
      people: people.toList(),
      places: places.toList(),
      suggestedTags: kind == null || kind == 'none' ? const [] : [kind],
      actionItems: actionItems,
      events: events,
      reminders: reminders,
      travelDetails: const [],
      analysedAt: analysedAt,
    );
  }

  static String? _text(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }

  static List<String> _strings(dynamic value, int limit) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .take(limit)
        .toList();
  }

  static List<String> _groundedItems(dynamic value, String speech) {
    final speechLower = speech.toLowerCase();
    final speechTokens = _tokens(speech);
    const filler = [
      'verify the result',
      'mark complete after verification',
      'mark it done after verification',
      'start work on ',
      'result verify',
      'done mark',
      'పని మొదలు',
      'ఫలితం verify',
      'काम शुरू',
      'नतीजा verify',
      'पूरा होने पर',
    ];
    return _strings(value, 12).where((item) {
      final lower = item.toLowerCase();
      if (filler.any(lower.contains)) return false;
      if (speechLower.contains(lower)) return true;
      final itemTokens = _tokens(item);
      if (itemTokens.isEmpty) return false;
      return itemTokens.intersection(speechTokens).length / itemTokens.length >=
          0.6;
    }).toList();
  }

  static Set<String> _tokens(String value) => value
      .toLowerCase()
      .split(RegExp(r'[^\p{L}\p{N}_]+', unicode: true))
      .where((token) => token.isNotEmpty)
      .toSet();

  static DateTime? _parseDate(dynamic date, dynamic time, DateTime base) {
    final dateText = _text(date);
    final timeText = _text(time);
    if (dateText != null) {
      final direct = DateTime.tryParse(
        timeText == null ? dateText : '${dateText}T$timeText',
      );
      if (direct != null) return direct;
    }

    final spoken = [dateText, timeText].whereType<String>().join(' ');
    if (spoken.isEmpty) return null;
    final lower = spoken.toLowerCase();
    var day = DateTime(base.year, base.month, base.day);
    if (RegExp(
      r'\b(?:tomorrow|repu)\b|రేపు|कल',
      caseSensitive: false,
    ).hasMatch(lower)) {
      day = day.add(const Duration(days: 1));
    } else {
      const weekdays = {
        'monday': DateTime.monday,
        'సోమవారం': DateTime.monday,
        'सोमवार': DateTime.monday,
        'tuesday': DateTime.tuesday,
        'మంగళవారం': DateTime.tuesday,
        'मंगलवार': DateTime.tuesday,
        'wednesday': DateTime.wednesday,
        'బుధవారం': DateTime.wednesday,
        'बुधवार': DateTime.wednesday,
        'thursday': DateTime.thursday,
        'గురువారం': DateTime.thursday,
        'गुरुवार': DateTime.thursday,
        'friday': DateTime.friday,
        'శుక్రవారం': DateTime.friday,
        'शुक्रवार': DateTime.friday,
        'saturday': DateTime.saturday,
        'శనివారం': DateTime.saturday,
        'शनिवार': DateTime.saturday,
        'sunday': DateTime.sunday,
        'ఆదివారం': DateTime.sunday,
        'रविवार': DateTime.sunday,
      };
      for (final entry in weekdays.entries) {
        if (!lower.contains(entry.key)) continue;
        var delta = (entry.value - day.weekday) % 7;
        if (delta == 0 ||
            lower.contains('next') ||
            lower.contains('వచ్చే') ||
            lower.contains('अगल')) {
          delta = delta == 0 ? 7 : delta;
        }
        day = day.add(Duration(days: delta));
        break;
      }
    }

    final numeric = RegExp(
      r'\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b',
      caseSensitive: false,
    ).firstMatch(lower);
    final words = RegExp(
      r'\b(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)\s*(am|pm)\b',
      caseSensitive: false,
    ).firstMatch(lower);
    int? hour;
    var minute = 0;
    String? meridiem;
    if (numeric != null) {
      hour = int.tryParse(numeric.group(1)!);
      minute = int.tryParse(numeric.group(2) ?? '0') ?? 0;
      meridiem = numeric.group(3)?.toLowerCase();
    } else if (words != null) {
      const hours = {
        'one': 1,
        'two': 2,
        'three': 3,
        'four': 4,
        'five': 5,
        'six': 6,
        'seven': 7,
        'eight': 8,
        'nine': 9,
        'ten': 10,
        'eleven': 11,
        'twelve': 12,
      };
      hour = hours[words.group(1)!.toLowerCase()];
      meridiem = words.group(2)!.toLowerCase();
    }
    if (hour == null) return null;
    if (meridiem == 'pm' && hour < 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  static String _safeTitle(String value) {
    final compact = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (compact.length <= 96) return compact;
    return '${compact.substring(0, 95).trimRight()}…';
  }

  static NoteType _noteType(
    String? kind,
    List<ActionItem> tasks,
    List<CalendarEvent> events,
    List<Reminder> reminders,
  ) {
    if (kind == 'meeting') return NoteType.meeting;
    if (kind == 'journal') return NoteType.journal;
    if (kind == 'idea') return NoteType.brainstorm;
    if (kind == 'task_list' || tasks.isNotEmpty) return NoteType.actionList;
    if (reminders.isNotEmpty) return NoteType.reminder;
    if (events.isNotEmpty) return NoteType.meeting;
    return NoteType.general;
  }
}
