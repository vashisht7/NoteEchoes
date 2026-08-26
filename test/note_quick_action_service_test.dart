import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/models/note_model.dart';
import 'package:notechoes_app/services/note_quick_action_service.dart';

void main() {
  NoteModel note({
    List<String> tags = const [],
    List<CheckListItem> checklist = const [],
    DateTime? reminderAt,
  }) => NoteModel(
    noteId: 'note',
    title: 'Test',
    contentType: NoteContentType.textOnly,
    summarySnippet: 'Test',
    textContent: 'Test content',
    createdAt: DateTime(2026, 8, 26),
    tags: tags,
    checklist: checklist,
    reminderAt: reminderAt,
  );

  test('classifies reminder, checklist, message, email and ordinary notes', () {
    expect(
      NoteQuickActionService.classify(note(tags: const ['reminders'])),
      NoteQuickActionKind.reminder,
    );
    expect(
      NoteQuickActionService.classify(
        note(
          checklist: [CheckListItem(id: '1', text: 'Ship')],
        ),
      ),
      NoteQuickActionKind.checklist,
    );
    expect(
      NoteQuickActionService.classify(note(tags: const ['message'])),
      NoteQuickActionKind.message,
    );
    expect(
      NoteQuickActionService.classify(note(tags: const ['email_draft'])),
      NoteQuickActionKind.email,
    );
    expect(NoteQuickActionService.classify(note()), NoteQuickActionKind.note);
  });

  test('reminder date survives note persistence JSON', () {
    final due = DateTime.utc(2026, 8, 26, 18, 31, 42);
    final restored = NoteModel.fromJson(note(reminderAt: due).toJson());
    expect(restored.reminderAt, due);
  });
}
