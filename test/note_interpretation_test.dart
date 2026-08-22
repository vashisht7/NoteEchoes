import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/domain/note_interpretation.dart';
import 'package:notechoes_app/ai/infrastructure/multilingual_interpretation_service.dart';

void main() {
  group('Multilingual Interpretation Unit Tests', () {
    test('Pass 1 Normalization strips fillers and self-corrections', () {
      const raw = 'Um uh I have a meeting on Tuesday wait no Wednesday at 4 PM like you know.';
      final normalized = MultilingualInterpretationService.normalizeTranscript(raw);

      expect(normalized, isNot(contains('um')));
      expect(normalized, isNot(contains('uh')));
      expect(normalized, isNot(contains('like you know')));
      expect(normalized, contains('Wednesday at 4 PM'));
    });

    test('Pass 2 extracts reminders and tasks in English', () async {
      const text = 'Remind me to submit the quarter taxes tomorrow at 5 PM.';
      final interpretation = await MultilingualInterpretationService.interpretNote(
        noteId: 'test-note-1',
        rawTranscript: text,
      );

      expect(interpretation.rawTranscript, equals(text));
      expect(interpretation.intents.any((i) => i.type == IntentType.reminder), isTrue);
      expect(interpretation.entities.any((e) => e.type == EntityType.dateTime), isTrue);
      expect(interpretation.provenance.modelId, isNotEmpty);
    });

    test('Extracts Telugu task and date intent', () async {
      const text = 'రేపు ఉదయం Rahul తో meeting schedule cheyali.';
      final interpretation = await MultilingualInterpretationService.interpretNote(
        noteId: 'test-note-2',
        rawTranscript: text,
      );

      expect(interpretation.primaryLanguage, anyOf(equals('te'), equals('mixed')));
      expect(
        interpretation.intents.any((i) => i.type == IntentType.task || i.type == IntentType.calendarEvent),
        isTrue,
      );
    });
  });
}
