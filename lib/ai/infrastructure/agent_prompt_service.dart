// agent_prompt_service.dart
// Detects and structures AI agent briefs / coding prompts suitable for Codex.
// Never invents files, APIs, or facts not present in note context.

import '../domain/note_interpretation.dart';

class AgentPromptService {
  static const double autoPreviewThreshold = 0.85;
  static const double suggestionThreshold = 0.60;

  // Positive intent signals
  static final _agentTriggers = [
    'create an agent prompt',
    'prompt for codex',
    'prompt for agent',
    'implement this feature',
    'refactor this class',
    'build a flutter widget',
    'write unit tests for',
    'add swift method channel',
    'fix this bug in code',
    'agent instructions',
    'implement instructions',
  ];

  // Negative non-agent signals (ordinary brainstorming, shopping, personal journals)
  static final _negativeTriggers = [
    'grocery list',
    'buy milk',
    'call mom',
    'workout routine',
    'diary entry',
    'recipe for',
  ];

  /// Detects whether the note text is an explicit or implicit agent prompt.
  static AgentPromptDraft? detectFromText(String noteText) {
    final lower = noteText.toLowerCase();

    for (final neg in _negativeTriggers) {
      if (lower.contains(neg)) return null;
    }

    double confidence = 0.0;
    for (final trigger in _agentTriggers) {
      if (lower.contains(trigger)) {
        confidence = 0.88;
        break;
      }
    }

    // Code block or technical instruction check
    if (noteText.contains('```') || noteText.contains('class ') || noteText.contains('func ') || noteText.contains('import ')) {
      confidence = confidence < 0.85 ? 0.85 : confidence;
    }

    if (confidence < suggestionThreshold) return null;

    // Parse structured brief sections
    final lines = noteText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final goal = lines.isNotEmpty ? lines.first.replaceAll(RegExp(r'^#+\s*'), '') : 'Implement NoteEchoes feature';
    final context = lines.length > 1 ? lines.sublist(1).take(3).join(' ') : 'Extracted from user note context.';

    final requirements = <String>[];
    final acceptanceCriteria = <String>[];
    final relevantFiles = <String>[];

    for (final line in lines) {
      if (line.startsWith('- ') || line.startsWith('* ') || line.startsWith('• ')) {
        requirements.add(line.substring(2).trim());
      }
      if (line.contains('.dart') || line.contains('.swift') || line.contains('.sqlite')) {
        final match = RegExp(r'[\w/_-]+\.(?:dart|swift|sqlite|json)').firstMatch(line);
        if (match != null) {
          final file = match.group(0)!;
          if (!relevantFiles.contains(file)) relevantFiles.add(file);
        }
      }
    }

    if (requirements.isEmpty) {
      requirements.add('Follow the implementation requirements specified in the note.');
    }

    acceptanceCriteria.add('Verified with automated unit tests.');
    acceptanceCriteria.add('Zero regressions in existing functionality.');

    return AgentPromptDraft(
      goal: goal,
      context: context,
      requirements: requirements,
      constraints: const [
        'Preserve local-first storage and privacy.',
        'Never overwrite raw user transcripts.',
        'Follow existing architecture and conventions.'
      ],
      acceptanceCriteria: acceptanceCriteria,
      relevantFiles: relevantFiles,
      nonGoals: const [
        'Do not introduce external cloud dependencies.'
      ],
      openQuestions: const [],
      confidence: confidence,
    );
  }
}
