import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/domain/ai_models.dart';
import 'package:notechoes_app/ai/infrastructure/prompt_repository.dart';

void main() {
  group('PromptRepository Tests', () {
    final prompts = PromptRepository.instance;

    test(
      'noteAnalysisPrompt generates valid AiMessage system and user prompts',
      () {
        final messages = prompts.noteAnalysisPrompt(
          noteContent:
              'Discussing project roadmap and next sprint deliverables.',
          noteId: 'test_note_1',
          noteCreatedAtIso8601: DateTime(2026, 8, 11).toIso8601String(),
        );

        expect(messages.length, equals(2));
        expect(messages[0].role, equals(AiRole.system));
        expect(messages[0].content, startsWith('[MODE: ACTION]'));
        expect(messages[0].content, contains('Core v5 schema'));
        expect(messages[1].role, equals(AiRole.user));
        expect(
          messages[1].content,
          equals('Discussing project roadmap and next sprint deliverables.'),
        );
      },
    );

    test('queryExpansionPrompt generates system prompt and user query', () {
      final messages = prompts.queryExpansionPrompt(
        query: 'vacation in Hawaii',
      );
      expect(messages.length, equals(2));
      expect(messages[0].role, equals(AiRole.system));
      expect(messages[1].content, equals('vacation in Hawaii'));
    });

    test('Core v5 prompt keeps the raw transcript unprefixed', () {
      final messages = prompts.coreV5ActionPrompt(
        rawTranscript: '  कल Priya को message draft करो  ',
      );
      expect(messages.length, 2);
      expect(messages.first.content, startsWith('[MODE: ACTION]'));
      expect(messages.first.content, contains('A tool output is a proposal'));
      expect(messages.last.content, 'कल Priya को message draft करो');
    });

    test('meetingSummaryPrompt structures meeting extraction request', () {
      final messages = prompts.meetingSummaryPrompt(
        transcript: 'Alice: Let us launch tomorrow. Bob: Agreed.',
      );
      expect(messages.length, equals(2));
      expect(messages[1].content, contains('Alice: Let us launch tomorrow'));
    });
  });
}
