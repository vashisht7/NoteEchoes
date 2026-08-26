import '../models/note_model.dart';
import 'note_tag_taxonomy.dart';

class PersonalMemoryAnswer {
  final String title;
  final String text;
  final List<NoteModel> sourceNotes;

  const PersonalMemoryAnswer({
    required this.title,
    required this.text,
    required this.sourceNotes,
  });
}

/// Answers common "external memory" questions from persisted note state.
/// This layer is deterministic: it filters dates, reminders, and checklist
/// state before any generative model is asked to phrase an answer.
class PersonalMemoryAnswerService {
  const PersonalMemoryAnswerService._();

  static PersonalMemoryAnswer? answer(
    String query,
    List<NoteModel> notes, {
    DateTime? now,
  }) {
    final lower = query.toLowerCase().trim();
    if (!_isMemoryQuery(lower)) return null;

    final localNow = (now ?? DateTime.now()).toLocal();
    final day = _requestedDay(lower, localNow);
    final wantsForgotten = RegExp(
      r'\b(?:forget|forgetting|forgot|missing|overdue|left|remaining|pending)\b|on my plate',
    ).hasMatch(lower);
    final wantsCompleted = RegExp(
      r'\b(?:completed|finished|done|accomplished)\b',
    ).hasMatch(lower);
    final wantsReminder = RegExp(
      r'\b(?:remind(?:er)?s?|due|appointments?|events?|schedule)\b',
    ).hasMatch(lower);
    final wantsDecision = RegExp(r'\bdecisions?\b').hasMatch(lower);
    final wantsIdea = RegExp(r'\bideas?\b').hasMatch(lower);
    final wantsCommunication = RegExp(
      r'\b(?:messages?|emails?|calls?|send|reply|follow.?ups?)\b',
    ).hasMatch(lower);
    final wantsTask = RegExp(
      r'\b(?:tasks?|checklists?|todo|to-do|wanted to do|need to do|plan(?:ned)?|work on)\b',
    ).hasMatch(lower);

    var candidates = notes.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (day != null) {
      candidates = candidates.where((note) {
        final created = note.createdAt.toLocal();
        final reminder = note.reminderAt?.toLocal();
        return _sameDay(created, day) ||
            (reminder != null && _sameDay(reminder, day));
      }).toList();
    }

    bool tagged(NoteModel note, Set<String> wanted) {
      final tags = NoteTagTaxonomy.normalize(note.tags).toSet();
      return tags.intersection(wanted).isNotEmpty;
    }

    if (wantsReminder) {
      candidates = candidates
          .where(
            (note) =>
                note.reminderAt != null ||
                tagged(note, {'reminders', 'events', 'meetings'}),
          )
          .toList();
    } else if (wantsDecision) {
      candidates = candidates.where((n) => tagged(n, {'decisions'})).toList();
    } else if (wantsIdea) {
      candidates = candidates.where((n) => tagged(n, {'ideas'})).toList();
    } else if (wantsCommunication) {
      candidates = candidates
          .where((n) => tagged(n, {'message', 'email', 'calls', 'follow-ups'}))
          .toList();
    } else if (wantsTask || wantsForgotten || wantsCompleted) {
      candidates = candidates
          .where(
            (note) =>
                note.checklist.isNotEmpty ||
                tagged(note, {'tasks', 'reminders'}),
          )
          .toList();
    }

    final label = _periodLabel(day, localNow);
    if (candidates.isEmpty) {
      final subject = wantsReminder
          ? 'reminders or events'
          : wantsDecision
          ? 'decisions'
          : wantsIdea
          ? 'ideas'
          : wantsCommunication
          ? 'messages or emails'
          : 'tasks';
      return PersonalMemoryAnswer(
        title: '$label memory',
        text: 'I could not find any $subject saved for ${label.toLowerCase()}.',
        sourceNotes: const [],
      );
    }

    final pending = <String>[];
    final completed = <String>[];
    final details = <String>[];
    for (final note in candidates) {
      if (note.checklist.isNotEmpty) {
        for (final item in note.checklist) {
          final value = '${item.text.trim()} — ${note.title.trim()}';
          if (item.isCompleted) {
            completed.add(value);
          } else {
            pending.add(value);
          }
        }
      } else {
        final body = _shortBody(note);
        details.add(
          body.isEmpty ? note.title.trim() : '${note.title.trim()}: $body',
        );
      }
    }

    final lines = <String>[];
    if (wantsReminder) {
      for (final note in candidates.take(8)) {
        final due = note.reminderAt?.toLocal();
        final time = due == null ? '' : ' at ${_clockTime(due)}';
        lines.add('• ${note.title.trim()}$time');
      }
    } else {
      if (!wantsCompleted && pending.isNotEmpty) {
        lines.add('Pending (${pending.length})');
        lines.addAll(pending.take(8).map((item) => '• $item'));
      }
      if (!wantsForgotten && completed.isNotEmpty) {
        lines.add('Currently completed (${completed.length})');
        lines.addAll(completed.take(6).map((item) => '• $item'));
      }
      if (details.isNotEmpty) {
        lines.addAll(details.take(8).map((item) => '• $item'));
      }
      if (lines.isEmpty && wantsCompleted) {
        lines.add('No matching items are currently marked complete.');
      }
    }

    final caveat = day != null && completed.isNotEmpty
        ? '\nCompletion dates are not stored yet, so “completed” means their current status in notes saved $label.'
        : '';
    return PersonalMemoryAnswer(
      title: '$label ${wantsReminder ? 'schedule' : 'memory'}',
      text: '${lines.join('\n')}$caveat',
      sourceNotes: candidates.take(8).toList(),
    );
  }

  static bool _isMemoryQuery(String query) {
    final hasQuestionIntent = RegExp(
      r'\b(?:what|which|who|when|where|show|tell|summari[sz]e|recap|review|remember|forget(?:ting)?|forgot|do i have|did i|need to|wanted to)\b|what.s on my plate',
    ).hasMatch(query);
    final hasMemorySubject = RegExp(
      r'\b(?:today|yesterday|tomorrow|tasks?|checklists?|todo|reminders?|due|pending|completed|finished|forget(?:ting)?|forgot|missing|overdue|decisions?|ideas?|messages?|emails?|calls?|reply|follow.?ups?|schedule|notes?)\b|on my plate',
    ).hasMatch(query);
    return hasQuestionIntent && hasMemorySubject;
  }

  static DateTime? _requestedDay(String query, DateTime now) {
    if (RegExp(r'\byesterday\b').hasMatch(query)) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 1));
    }
    if (RegExp(r'\btomorrow\b').hasMatch(query)) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
    }
    if (RegExp(r'\btoday\b').hasMatch(query)) {
      return DateTime(now.year, now.month, now.day);
    }
    return null;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _periodLabel(DateTime? day, DateTime now) {
    if (day == null) return 'Your';
    final today = DateTime(now.year, now.month, now.day);
    final difference = day.difference(today).inDays;
    if (difference == -1) return 'Yesterday’s';
    if (difference == 0) return 'Today’s';
    if (difference == 1) return 'Tomorrow’s';
    return '${day.month}/${day.day}/${day.year}';
  }

  static String _shortBody(NoteModel note) {
    final raw = note.textContent.trim().isNotEmpty
        ? note.textContent.trim()
        : note.summarySnippet.trim();
    if (raw.length <= 140) return raw;
    return '${raw.substring(0, 137).trimRight()}…';
  }

  static String _clockTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
  }
}
