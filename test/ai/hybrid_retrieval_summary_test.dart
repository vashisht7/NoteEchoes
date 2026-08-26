import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/infrastructure/hybrid_retrieval_service.dart';

void main() {
  test(
    'summary requests produce a readable grounded report with citations',
    () async {
      const candidates = [
        HybridCandidate(
          noteId: 'launch-plan',
          title: 'Launch plan',
          passageText: 'Ship the English-first release after device testing.',
          rrfScore: 1,
        ),
        HybridCandidate(
          noteId: 'customer-feedback',
          title: 'Customer feedback',
          passageText:
              'Users asked for clearer reports and reliable reminders.',
          rrfScore: .8,
        ),
      ];

      final result = await HybridRetrievalService.answerQuery(
        query: 'Summarize my notes',
        candidates: candidates,
        queryLanguage: 'en',
      );

      expect(result.displayText, startsWith('Based on your saved notes:'));
      expect(result.displayText, contains('Launch plan:'));
      expect(result.displayText, contains('[1]'));
      expect(result.displayText, contains('Customer feedback:'));
      expect(result.displayText, contains('[2]'));
      expect(result.sourceNoteIds, ['launch-plan', 'customer-feedback']);
      expect(
        result.provenance.modelId,
        'deterministic_grounded_extractive_report',
      );
    },
  );
}
