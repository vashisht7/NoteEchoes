import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/domain/core_action_v5.dart';
import 'package:notechoes_app/ai/domain/core_action_v5_adapter.dart';
import 'package:notechoes_app/ai/domain/note_analysis.dart';

void main() {
  test('maps a validated checklist without executing its tool proposal', () {
    final parsed = const CoreV5Validator().parseAndValidate(
      {
        'schema_version': 5,
        'language': 'en',
        'mode': 'capture',
        'normalized_text':
            'Create a checklist with charge the recorder and pack the cable.',
        'intent': 'checklist',
        'title': 'Recording Checklist',
        'items': [
          {'text': 'charge the recorder'},
          {'text': 'pack the cable'},
        ],
        'entities': {
          'recipient_query': null,
          'date_phrase': null,
          'time_phrase': null,
          'people': <String>[],
          'place': null,
          'subject': null,
        },
        'draft': null,
        'proposed_tool': {
          'name': 'checklists.create',
          'arguments': {
            'normalized_text':
                'Create a checklist with charge the recorder and pack the cable.',
          },
        },
        'confidence': 0.98,
        'requires_confirmation': false,
        'clarification_question': null,
      },
      rawTranscript:
          'create a checklist with charge the recorder and pack the cable',
    );

    expect(parsed.isValid, isTrue, reason: parsed.errors.join('\n'));
    final result = CoreActionV5Adapter.toNoteAnalysis(
      parsed.value!,
      noteContent:
          'create a checklist with charge the recorder and pack the cable',
      noteId: 'note-1',
      modelVersion: 'english-action-release',
      analysedAt: DateTime.utc(2026, 8, 26),
    );

    expect(result.noteType, NoteType.actionList);
    expect(result.generatedTitle, 'Recording Checklist');
    expect(result.actionItems.map((item) => item.task), [
      'charge the recorder',
      'pack the cable',
    ]);
    expect(result.reminders, isEmpty);
    expect(result.events, isEmpty);
  });

  test('keeps a reminder as a note-level proposal with no side effect', () {
    final envelope = CoreV5Envelope(
      schemaVersion: 5,
      language: 'en',
      mode: 'capture',
      normalizedText: 'Remind me tomorrow at 6 PM to call Priya.',
      intent: 'reminder',
      title: 'Call Priya',
      items: const [],
      entities: const CoreV5Entities(
        datePhrase: 'tomorrow',
        timePhrase: 'at 6 PM',
        people: ['Priya'],
      ),
      draft: null,
      proposedTool: const CoreV5ToolProposal(
        name: 'reminders.propose',
        arguments: {},
      ),
      confidence: 0.98,
      requiresConfirmation: true,
      clarificationQuestion: null,
    );
    final result = CoreActionV5Adapter.toNoteAnalysis(
      envelope,
      noteContent: 'remind me tomorrow at 6 PM to call Priya',
      noteId: 'note-2',
      modelVersion: 'english-action-release',
      analysedAt: DateTime.utc(2026, 8, 26),
    );
    expect(result.noteType, NoteType.reminder);
    expect(result.reminders, isEmpty);
    expect(result.events, isEmpty);
  });
}
