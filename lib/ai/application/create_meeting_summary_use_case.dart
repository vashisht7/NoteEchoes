// create_meeting_summary_use_case.dart
// Generates a structured meeting summary from a note and optional transcript.

import '../providers/text_generation_provider.dart';
import '../infrastructure/prompt_repository.dart';
import '../domain/note_analysis.dart';
import '../domain/ai_models.dart';
import '../domain/transcript.dart';
import '../../models/note_model.dart';

class CreateMeetingSummaryUseCase {
  final TextGenerationProvider llm;
  final PromptRepository prompts;

  CreateMeetingSummaryUseCase(this.llm, this.prompts)
      : assert(llm != null),
        assert(prompts != null);

  Future<NoteAnalysisResult> execute(
    NoteModel meetingNote, {
    TranscriptResult? transcript,
  }) async {
    String textToAnalyse = meetingNote.textContent;

    if (transcript != null && transcript.fullText.isNotEmpty) {
      textToAnalyse =
          '[Transcript]\n${transcript.fullText}\n\n[Notes]\n$textToAnalyse';
    }

    return llm.generateNoteAnalysis(
      textToAnalyse,
      noteId: meetingNote.noteId,
      noteCreatedAt: meetingNote.createdAt,
      existingTranscript: transcript?.fullText,
    );
  }
}
