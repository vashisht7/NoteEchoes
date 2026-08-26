import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/models/note_model.dart';
import 'package:notechoes_app/services/personal_memory_answer_service.dart';

NoteModel note({
  required String id,
  required String title,
  required DateTime createdAt,
  List<String> tags = const [],
  List<CheckListItem> checklist = const [],
  DateTime? reminderAt,
}) => NoteModel(
  noteId: id,
  title: title,
  contentType: NoteContentType.textOnly,
  summarySnippet: '',
  textContent: '',
  createdAt: createdAt,
  tags: tags,
  checklist: checklist,
  reminderAt: reminderAt,
);

void main() {
  final now = DateTime(2026, 8, 26, 10);

  test('answers what I wanted to do yesterday from checklist state', () {
    final answer = PersonalMemoryAnswerService.answer(
      'What did I want to do yesterday?',
      [
        note(
          id: 'yesterday',
          title: 'App release',
          createdAt: DateTime(2026, 8, 25, 14),
          tags: ['task_list'],
          checklist: [
            CheckListItem(id: '1', text: 'Test reminders'),
            CheckListItem(id: '2', text: 'Build app', isCompleted: true),
          ],
        ),
        note(
          id: 'today',
          title: 'Unrelated today',
          createdAt: DateTime(2026, 8, 26),
          tags: ['tasks'],
        ),
      ],
      now: now,
    );

    expect(answer, isNotNull);
    expect(answer!.title, 'Yesterday’s memory');
    expect(answer.text, contains('Test reminders'));
    expect(answer.text, contains('Build app'));
    expect(answer.text, isNot(contains('Unrelated today')));
    expect(answer.text, contains('Completion dates are not stored'));
  });

  test('finds tomorrow reminder by due date, not creation date', () {
    final answer = PersonalMemoryAnswerService.answer(
      'What reminders do I have tomorrow?',
      [
        note(
          id: 'reminder',
          title: 'Check app',
          createdAt: DateTime(2026, 8, 20),
          tags: ['reminder'],
          reminderAt: DateTime(2026, 8, 27, 9, 5),
        ),
      ],
      now: now,
    );

    expect(answer, isNotNull);
    expect(answer!.title, 'Tomorrow’s schedule');
    expect(answer.text, contains('Check app at 9:05 AM'));
  });

  test('answers forgotten work from pending items only', () {
    final answer = PersonalMemoryAnswerService.answer(
      'What am I forgetting or leaving pending?',
      [
        note(
          id: 'tasks',
          title: 'Launch',
          createdAt: now,
          checklist: [
            CheckListItem(id: '1', text: 'Upload build'),
            CheckListItem(id: '2', text: 'Old completed', isCompleted: true),
          ],
        ),
      ],
      now: now,
    );

    expect(answer, isNotNull);
    expect(answer!.text, contains('Upload build'));
    expect(answer.text, isNot(contains('Old completed')));
  });

  test('answers the short exact what am I forgetting question', () {
    final answer = PersonalMemoryAnswerService.answer('What am I forgetting?', [
      note(
        id: 'pending',
        title: 'Release',
        createdAt: now,
        tags: ['task'],
        checklist: [CheckListItem(id: '1', text: 'Check App Store copy')],
      ),
    ], now: now);

    expect(answer, isNotNull);
    expect(answer!.text, contains('Check App Store copy'));
  });

  test('recalls calls and follow-ups without mixing unrelated notes', () {
    final answer = PersonalMemoryAnswerService.answer(
      'Who do I need to call or follow up with?',
      [
        note(
          id: 'call',
          title: 'Call Ravi',
          createdAt: now,
          tags: ['phone_call'],
        ),
        note(
          id: 'idea',
          title: 'Unrelated idea',
          createdAt: now,
          tags: ['idea'],
        ),
      ],
      now: now,
    );

    expect(answer, isNotNull);
    expect(answer!.text, contains('Call Ravi'));
    expect(answer.text, isNot(contains('Unrelated idea')));
  });

  test('recalls decisions from the requested day', () {
    final answer = PersonalMemoryAnswerService.answer(
      'What decisions did I make yesterday?',
      [
        note(
          id: 'decision',
          title: 'Use the 8-bit model',
          createdAt: DateTime(2026, 8, 25, 18),
          tags: ['decision'],
        ),
      ],
      now: now,
    );

    expect(answer, isNotNull);
    expect(answer!.text, contains('Use the 8-bit model'));
  });

  test('does not intercept an unrelated knowledge question', () {
    expect(
      PersonalMemoryAnswerService.answer(
        'Explain transformer attention',
        const [],
        now: now,
      ),
      isNull,
    );
  });
}
