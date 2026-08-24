import '../models/note_model.dart';

class ChecklistStatusAnswer {
  final String text;
  final NoteModel note;

  const ChecklistStatusAnswer({required this.text, required this.note});
}

/// Answers checklist-progress questions from the live persisted note state.
/// Counts never depend on model inference, so completed/pending answers remain
/// correct immediately after a checkbox is tapped.
class ChecklistStatusService {
  const ChecklistStatusService._();

  static ChecklistStatusAnswer? answer(String query, List<NoteModel> notes) {
    if (!_isChecklistStatusQuery(query)) return null;
    final checklists = notes.where((note) => note.checklist.isNotEmpty).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (checklists.isEmpty) return null;

    final lower = query.toLowerCase();
    final matched = checklists.where((note) {
      final terms = note.title
          .toLowerCase()
          .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
          .where((term) => term.length >= 3);
      return terms.any(lower.contains);
    });
    final note = matched.isNotEmpty ? matched.first : checklists.first;
    final completed = note.checklist.where((item) => item.isCompleted).toList();
    final pending = note.checklist.where((item) => !item.isCompleted).toList();
    final language = _language(query);

    final text = switch (language) {
      'te' =>
        '${note.title}లో మొత్తం ${note.checklist.length} పనులు ఉన్నాయి. '
            '${completed.length} పూర్తయ్యాయి, ${pending.length} ఇంకా మిగిలి ఉన్నాయి.'
            '${_pendingSuffix(pending, 'మిగిలినవి')}',
      'hi' =>
        '${note.title} में कुल ${note.checklist.length} काम हैं। '
            '${completed.length} पूरे हुए हैं और ${pending.length} बाकी हैं।'
            '${_pendingSuffix(pending, 'बाकी काम')}',
      _ =>
        '${note.title} has ${note.checklist.length} tasks: '
            '${completed.length} completed and ${pending.length} pending.'
            '${_pendingSuffix(pending, 'Pending')}',
    };

    return ChecklistStatusAnswer(text: text, note: note);
  }

  static bool _isChecklistStatusQuery(String value) => RegExp(
    r'\b(?:checklist|tasks?|todo|pending|completed|done|left|remaining)\b|'
    r'చెక్.?లిస్ట్|పనులు|పని|పూర్తి|మిగిలి|బాకీ|'
    r'चेकलिस्ट|काम|कार्य|पूरा|बाकी|लंबित',
    caseSensitive: false,
  ).hasMatch(value);

  static String _language(String value) {
    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(value)) return 'te';
    if (RegExp(r'[\u0900-\u097F]').hasMatch(value)) return 'hi';
    return 'en';
  }

  static String _pendingSuffix(List<CheckListItem> pending, String label) {
    if (pending.isEmpty) return '';
    final items = pending.take(3).map((item) => item.text).join(', ');
    return ' $label: $items.';
  }
}
