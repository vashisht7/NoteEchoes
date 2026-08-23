import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/domain/core_action_v4_adapter.dart';
import 'package:notechoes_app/ai/domain/core_action_v4_guardrails.dart';

void main() {
  test('maps a spoken Telugu checklist into existing action items', () {
    const speech = 'చెక్‌లిస్ట్: పాలు కొనాలి, రవికి కాల్ చేయాలి';
    final result = CoreActionV4Adapter.toNoteAnalysis(
      {
        'v': 4,
        'language': 'te',
        'mode': 'capture',
        'kind': 'task_list',
        'title': 'ఈరోజు చెక్‌లిస్ట్',
        'summary': speech,
        'actions': [
          {
            'kind': 'task',
            'text': 'ఈరోజు పనులు',
            'items': ['పాలు కొనాలి', 'రవికి కాల్ చేయాలి'],
            'date': null,
            'time': null,
            'people': [],
            'place': null,
          },
        ],
        'query_terms': [],
        'ask': null,
      },
      noteContent: speech,
      noteId: 'n1',
      modelVersion: 'core-v4',
      analysedAt: DateTime(2026),
    );

    expect(result.generatedTitle, 'ఈరోజు చెక్‌లిస్ట్');
    expect(result.actionItems.map((item) => item.task), [
      'పాలు కొనాలి',
      'రవికి కాల్ చేయాలి',
    ]);
  });

  test('keeps reminders pending in the existing review flow', () {
    final result = CoreActionV4Adapter.toNoteAnalysis(
      {
        'v': 4,
        'language': 'hi',
        'mode': 'capture',
        'kind': 'note',
        'title': 'रवि को याद दिलाना',
        'summary': 'कल रवि को कॉल करने की याद दिलाना',
        'actions': [
          {
            'kind': 'reminder',
            'text': 'रवि को कॉल करना',
            'items': [],
            'date': '2026-08-23',
            'time': '09:00:00',
            'people': ['रवि'],
            'place': null,
          },
        ],
        'query_terms': [],
        'ask': null,
      },
      noteContent: 'कल रवि को कॉल करने की याद दिलाना',
      noteId: 'n2',
      modelVersion: 'core-v4',
      analysedAt: DateTime(2026),
    );

    expect(result.reminders.single.title, 'रवि को कॉल करना');
    expect(result.reminders.single.triggerDate, DateTime(2026, 8, 23, 9));
  });

  group('Core v4 product guardrails', () {
    test('routes Telugu and Hindi schedule commands to calendar events', () {
      for (final sample in [
        ('te', 'వచ్చే సోమవారం 3కి మాయతో NoteEchoes review schedule చెయ్యి.'),
        (
          'hi',
          'अगले सोमवार 3 बजे माया के साथ NoteEchoes review schedule कर दो।',
        ),
      ]) {
        final guarded = CoreActionV4Guardrails.normalize({
          'v': 4,
          'language': sample.$1,
          'mode': 'capture',
          'kind': 'note',
          'actions': [
            {
              'kind': 'reminder',
              'text': sample.$2,
              'items': [],
              'date': null,
              'time': sample.$2,
              'people': [],
              'place': null,
            },
          ],
          'ask': null,
        }, noteContent: sample.$2);
        expect((guarded['actions'] as List).single['kind'], 'calendar_event');
      }
    });

    test('resolves a spoken Telugu next-Monday calendar time for review', () {
      const speech =
          'వచ్చే సోమవారం 3కి మాయతో NoteEchoes review schedule చెయ్యి.';
      final guarded = CoreActionV4Guardrails.normalize({
        'v': 4,
        'language': 'te',
        'mode': 'capture',
        'kind': 'note',
        'title': 'NoteEchoes review',
        'summary': speech,
        'actions': [
          {
            'kind': 'reminder',
            'text': 'మాయతో NoteEchoes review',
            'items': [],
            'date': null,
            'time': 'వచ్చే సోమవారం 3కి',
            'people': ['మాయ'],
            'place': null,
          },
        ],
        'query_terms': [],
        'ask': null,
      }, noteContent: speech);
      final result = CoreActionV4Adapter.toNoteAnalysis(
        guarded,
        noteContent: speech,
        noteId: 'calendar-te',
        modelVersion: 'core-v4',
        analysedAt: DateTime(2026, 8, 22),
      );
      expect(result.events.single.startDate, DateTime(2026, 8, 24, 3));
      expect(result.events.single.attendees, ['మాయ']);
    });

    test('does not create actions from explicit Telugu negative commands', () {
      for (final sample in [
        ('te', 'ఇది rough thought మాత్రమే, task create చేయొద్దు.'),
        ('te-roman', 'idi just thought matrame, reminder pettoddu.'),
      ]) {
        final guarded = CoreActionV4Guardrails.normalize({
          'language': sample.$1,
          'kind': 'task_list',
          'actions': [
            {'kind': 'task', 'text': sample.$2},
          ],
        }, noteContent: sample.$2);
        expect(guarded['kind'], 'idea');
        expect(guarded['actions'], isEmpty);
      }
    });

    test('asks for a missing reminder time in all supported languages', () {
      for (final sample in [
        ('en', 'Remind me later to check the oven.'),
        ('te', 'తర్వాత అమ్మకి call చేయాలని గుర్తు చెయ్యి.'),
        ('hi', 'बाद में मुझे रिपोर्ट भेजने की याद दिलाना।'),
      ]) {
        final guarded = CoreActionV4Guardrails.normalize({
          'language': sample.$1,
          'kind': 'note',
          'actions': [
            {'kind': 'reminder', 'text': sample.$2, 'date': null, 'time': null},
          ],
          'ask': null,
        }, noteContent: sample.$2);
        expect(guarded['ask'], isNotNull);
      }
    });

    test('treats a Hindi vague-time token as missing time', () {
      const speech = 'बाद में मुझे रिपोर्ट भेजने की याद दिलाना।';
      final guarded = CoreActionV4Guardrails.normalize({
        'language': 'hi',
        'kind': 'note',
        'actions': [
          {'kind': 'reminder', 'text': speech, 'date': null, 'time': 'बाद'},
        ],
        'ask': null,
      }, noteContent: speech);
      expect(guarded['ask'], isNotNull);
    });

    test('asks for a specific time when only a part of day is spoken', () {
      for (final sample in [
        ('en', 'Set a reminder in the evening to call Ravi.', 'evening'),
        ('te', 'సాయంత్రం రవికి call చేయడం గుర్తు చెయ్యి.', 'సాయంత్రం'),
        ('hi', 'शाम को रवि को call करना याद दिलाना।', 'शाम'),
      ]) {
        final guarded = CoreActionV4Guardrails.normalize({
          'language': sample.$1,
          'kind': 'note',
          'actions': [
            {
              'kind': 'reminder',
              'text': sample.$2,
              'date': null,
              'time': sample.$3,
            },
          ],
          'ask': null,
        }, noteContent: sample.$2);
        expect(guarded['ask'], isNotNull);
      }
    });

    test('splits a Telugu task plus reminder and preserves project updates', () {
      const speech =
          'Design పంపడం task list లో పెట్టి, శుక్రవారం ఉదయం గుర్తు చెయ్యి.';
      final guarded = CoreActionV4Guardrails.normalize({
        'language': 'te',
        'kind': 'task_list',
        'actions': [
          {'kind': 'task', 'text': 'Design పంపడం', 'time': 'శుక్రవారం ఉదయం'},
        ],
      }, noteContent: speech);
      expect((guarded['actions'] as List).map((action) => action['kind']), [
        'task',
        'reminder',
      ]);

      final update = CoreActionV4Guardrails.normalize(
        {'language': 'hi', 'kind': 'note', 'actions': []},
        noteContent:
            'NoteEchoes update: download ठीक हो गया है, Telugu testing अभी बाकी है।',
      );
      expect(update['kind'], 'project_update');
    });

    test('keeps mixed mind dumps as notes and respects no-reminder clauses', () {
      const text =
          'आज बहुत कुछ सोचा home screen simple रखना है Ravi से Friday बात करनी है इसे task में डाल दो और अगले हफ्ते मां के birthday gift का बस note रखो reminder मत लगाना';
      final guarded = CoreActionV4Guardrails.normalize({
        'language': 'hi',
        'kind': 'task_list',
        'actions': [
          {'kind': 'task', 'text': 'Ravi से Friday बात करनी है'},
          {'kind': 'reminder', 'text': 'मां के birthday gift'},
        ],
      }, noteContent: text);
      expect(guarded['kind'], 'note');
      expect((guarded['actions'] as List).map((action) => action['kind']), [
        'task',
      ]);
    });

    test('splits Telugu and Hindi roman ASR into reminder plus task', () {
      for (final sample in [
        (
          'te-roman',
          'repu six pm ravi call reminder pettu and design send cheyyadam task lo add cheyyi',
        ),
        (
          'hi-roman',
          'kal six pm ravi ko call reminder laga do aur design send karna task mein add karo',
        ),
      ]) {
        final guarded = CoreActionV4Guardrails.normalize({
          'language': sample.$1,
          'kind': 'task_list',
          'actions': [
            {'kind': 'task', 'text': sample.$2},
          ],
        }, noteContent: sample.$2);
        expect((guarded['actions'] as List).map((action) => action['kind']), [
          'reminder',
          'task',
        ]);
      }
    });

    test('splits common native and mixed task plus reminder phrasing', () {
      for (final sample in [
        (
          'en',
          'Save send the design in tasks, then prompt me tomorrow at 6 PM.',
        ),
        (
          'te',
          'design పంపడం track చెయ్యి, అలాగే రేపు సాయంత్రం 6కి notification propose చెయ్యి.',
        ),
        (
          'te',
          'Please design send చేయడం list లో పెట్టు, అలాగే Friday morning గుర్తు చెయ్యి.',
        ),
        (
          'te-roman',
          'design send cheyyadam list lo pettu, alage repu 6 PM ki gurthu cheyyi.',
        ),
        (
          'hi',
          'Please design भेजना list में डालो, साथ में कल 6 PM पर याद दिलाओ।',
        ),
        (
          'hi-roman',
          'design send karna list mein dalo saath mein kal 6 PM par yaad dilao.',
        ),
      ]) {
        final guarded = CoreActionV4Guardrails.normalize({
          'language': sample.$1,
          'kind': 'note',
          'actions': <Map<String, dynamic>>[],
        }, noteContent: sample.$2);
        expect(guarded['kind'], 'task_list');
        expect((guarded['actions'] as List).map((action) => action['kind']), [
          'task',
          'reminder',
        ]);
      }
    });

    test(
      'keeps brainstorming as an idea even if the model calls it a query',
      () {
        const speech =
            'show related notes గురించి brainstorm చేస్తున్నాను; action వద్దు.';
        final guarded = CoreActionV4Guardrails.normalize({
          'language': 'te',
          'mode': 'query',
          'kind': 'none',
          'actions': <Map<String, dynamic>>[],
          'query_terms': ['show related notes'],
        }, noteContent: speech);
        expect(guarded['mode'], 'capture');
        expect(guarded['kind'], 'idea');
        expect(guarded['query_terms'], isEmpty);
      },
    );

    test('meeting context does not turn a reminder into a calendar event', () {
      const speech =
          'Atlas meeting ముందు release notes check చేయాలని గుర్తు చెయ్యి.';
      final guarded = CoreActionV4Guardrails.normalize({
        'language': 'te',
        'mode': 'capture',
        'kind': 'note',
        'actions': [
          {'kind': 'reminder', 'text': speech},
        ],
      }, noteContent: speech);
      expect((guarded['actions'] as List).single['kind'], 'reminder');
    });
  });
}
