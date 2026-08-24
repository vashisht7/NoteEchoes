import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/models/note_model.dart';
import 'package:notechoes_app/services/checklist_status_service.dart';

void main() {
  test('answers live completed and pending checklist counts', () {
    final note = NoteModel(
      noteId: 'list-1',
      title: 'Release Checklist',
      createdAt: DateTime(2026, 8, 23),
      contentType: NoteContentType.textOnly,
      summarySnippet: '',
      textContent: '',
      checklist: [
        CheckListItem(id: '1', text: 'Test model', isCompleted: true),
        CheckListItem(id: '2', text: 'Test app'),
        CheckListItem(id: '3', text: 'Ship release'),
      ],
    );

    final answer = ChecklistStatusService.answer(
      'How many tasks are done and pending?',
      [note],
    );

    expect(answer, isNotNull);
    expect(answer!.text, contains('3 tasks'));
    expect(answer.text, contains('1 completed'));
    expect(answer.text, contains('2 pending'));
    expect(answer.text, contains('Test app'));
  });

  test('does not intercept an unrelated note question', () {
    expect(
      ChecklistStatusService.answer('What did Ravi say?', const []),
      isNull,
    );
  });
}
