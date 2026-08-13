// journal_review_use_case.dart
// Weekly and daily journal reflection using the local LLM.

import '../providers/text_generation_provider.dart';
import '../infrastructure/prompt_repository.dart';
import '../domain/ai_models.dart';
import '../config/ai_feature_flags.dart';
import '../../models/note_model.dart';

class JournalReviewUseCase {
  final TextGenerationProvider llm;
  final PromptRepository prompts;

  JournalReviewUseCase(this.llm, this.prompts);

  Future<String> generateWeeklyReview({
    required List<NoteModel> weekNotes,
    required DateTime weekStart,
  }) async {
    if (!AiFeatureFlags.instance.journalingMemoryEnabled) {
      throw Exception(
          'Journaling memory is disabled. Enable it from Settings → AI Models.');
    }

    if (weekNotes.isEmpty) return 'No notes found for this week.';

    final notes = weekNotes.map((n) => '${n.title}\n${n.textContent}').join('\n\n---\n\n');
    final messages = prompts.journalReflectionPrompt(
      notes: notes,
      weekStart: weekStart,
    );
    return llm.generate(messages,
        options: const GenerationOptions(maxTokens: 768, temperature: 0.5));
  }

  Future<String> generateDailyReflection({
    required NoteModel journalNote,
  }) async {
    if (!AiFeatureFlags.instance.journalingMemoryEnabled) {
      throw Exception('Journaling memory is disabled.');
    }

    final messages = prompts.journalReflectionPrompt(
      notes: '${journalNote.title}\n${journalNote.textContent}',
      weekStart: journalNote.createdAt,
    );
    return llm.generate(messages,
        options: const GenerationOptions(maxTokens: 512, temperature: 0.5));
  }
}
