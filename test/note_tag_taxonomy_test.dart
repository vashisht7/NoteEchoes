import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/services/note_tag_taxonomy.dart';

void main() {
  test('collapses task aliases and removes duplicates', () {
    expect(
      NoteTagTaxonomy.normalize([
        '#task',
        'tasks',
        'task_list',
        'checklist',
        'To Do',
      ]),
      ['tasks'],
    );
  });

  test(
    'canonicalizes common semantic aliases without damaging system tags',
    () {
      expect(
        NoteTagTaxonomy.normalize([
          'Reminder',
          'calendar_event',
          'email_draft',
          'SMS',
          'voice-memo',
          'reminder-scheduled',
        ]),
        [
          'reminders',
          'events',
          'email',
          'message',
          'voice-memo',
          'reminder-scheduled',
        ],
      );
    },
  );
}
