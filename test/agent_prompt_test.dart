import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/infrastructure/agent_prompt_service.dart';

void main() {
  group('AgentPromptService Tests', () {
    test('Detects explicit coding agent prompt and generates Codex markdown', () {
      const note = '''
# Implement WhisperModelManager actor
Create an agent prompt for Codex:
- Add Swift actor in ios/Runner/WhisperModelManager.swift
- Implement download and load methods
- Check AudioEncoder.mlmodelc existence
''';

      final draft = AgentPromptService.detectFromText(note);
      expect(draft, isNotNull);
      expect(draft!.goal, contains('Implement WhisperModelManager actor'));
      expect(draft.relevantFiles, contains('ios/Runner/WhisperModelManager.swift'));

      final codexMd = draft.toCodexMarkdown();
      expect(codexMd, contains('## Requirements'));
      expect(codexMd, contains('## Constraints'));
      expect(codexMd, contains('## Acceptance Criteria'));
    });

    test('Rejects non-agent ordinary notes', () {
      const note = 'Grocery list: buy milk, bananas, and call mom tonight.';
      final draft = AgentPromptService.detectFromText(note);
      expect(draft, isNull);
    });
  });
}
