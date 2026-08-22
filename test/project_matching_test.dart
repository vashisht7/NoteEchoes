import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/infrastructure/project_matching_service.dart';

void main() {
  group('ProjectMatchingService Tests', () {
    const known = ['NoteEchoes', 'PulseHealth', 'ApolloPortal'];

    test('Exact phrase match yields high confidence suggestion', () {
      final candidates = ProjectMatchingService.matchCandidates(
        noteText: 'We need to fix WhisperKit model downloading in NoteEchoes app.',
        knownProjects: known,
      );

      expect(candidates.isNotEmpty, isTrue);
      expect(candidates.first.projectName, equals('NoteEchoes'));
      expect(candidates.first.confidence, greaterThanOrEqualTo(ProjectMatchingService.autoSuggestThreshold));
    });

    test('Unrelated note yields no project candidate', () {
      final candidates = ProjectMatchingService.matchCandidates(
        noteText: 'Buy groceries from the supermarket: milk, eggs, bread.',
        knownProjects: known,
      );

      expect(candidates.isEmpty, isTrue);
    });

    test('Validates LLM proposal against known projects only', () {
      final candidates = ProjectMatchingService.matchCandidates(
        noteText: 'Discuss sprint velocity for the team.',
        knownProjects: known,
        llmProposedProject: 'GhostUnknownProject',
        llmConfidence: 0.95,
      );

      expect(candidates.any((c) => c.projectName == 'GhostUnknownProject'), isFalse);
    });
  });
}
