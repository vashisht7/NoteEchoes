/// Canonical user-facing tags. The app may receive tags from rules, imported
/// notes, or local models, but equivalent spellings must never fragment the
/// library into separate filters.
class NoteTagTaxonomy {
  const NoteTagTaxonomy._();

  static const Map<String, String> _aliases = {
    'task': 'tasks',
    'task-list': 'tasks',
    'tasklist': 'tasks',
    'todo': 'tasks',
    'todos': 'tasks',
    'to-do': 'tasks',
    'checklist': 'tasks',
    'checklists': 'tasks',
    'reminder': 'reminders',
    'idea': 'ideas',
    'meeting': 'meetings',
    'event': 'events',
    'calendar': 'events',
    'calendar-event': 'events',
    'email-draft': 'email',
    'e-mail': 'email',
    'mail': 'email',
    'message-draft': 'message',
    'sms': 'message',
    'text-message': 'message',
    'call': 'calls',
    'phone-call': 'calls',
    'callback': 'calls',
    'followup': 'follow-ups',
    'follow-up': 'follow-ups',
    'note': 'notes',
    'plain-note': 'notes',
    'document': 'documents',
    'pdf': 'documents',
    'decision': 'decisions',
    'project-update': 'projects',
  };

  static String canonical(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceFirst(RegExp(r'^#+'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-');
    return _aliases[normalized] ?? normalized;
  }

  static List<String> normalize(Iterable<String> values) {
    final result = <String>[];
    final seen = <String>{};
    for (final value in values) {
      final tag = canonical(value);
      if (tag.isNotEmpty && seen.add(tag)) result.add(tag);
    }
    return result;
  }
}
