import '../domain/ai_models.dart';

class PromptRepository {
  static final PromptRepository _instance = PromptRepository._internal();
  static PromptRepository get instance => _instance;

  factory PromptRepository() {
    return _instance;
  }

  PromptRepository._internal();

  static const String promptVersion = 'v1.0';

  List<AiMessage> noteAnalysisPrompt({
    required String noteContent,
    required String noteId,
    required String noteCreatedAtIso8601,
    String? existingTranscript,
  }) {
    final systemPrompt = '''
You are a local AI assistant analysing personal notes. Output ONLY valid JSON.
Detect language (en/te/hi). Generate a minimal 3-6 word title.
Extract: topics, people, places, action_items, events, reminders, travel_details.
For dates: resolve relative expressions using the provided note_created_at ($noteCreatedAtIso8601) as base date.
Output schema: { 
  "note_id": "$noteId", 
  "model_version": "$promptVersion", 
  "detected_language": "string", 
  "note_type": "string", 
  "generated_title": "string", 
  "summary": "string", 
  "english_retrieval_summary": "string", 
  "topics": ["string"], 
  "people": ["string"], 
  "places": ["string"], 
  "suggested_tags": ["string"], 
  "action_items": ["string"], 
  "events": ["string"], 
  "reminders": ["string"], 
  "travel_details": ["string"], 
  "analysed_at": "string" 
}
Confidence must be 0.0-1.0. Mark uncertain dates with `is_uncertain: true`.
''';

    final userContent = existingTranscript != null
        ? 'Note Transcript: $existingTranscript\n\nNote Content: $noteContent'
        : 'Note Content: $noteContent';

    return [
      AiMessage(role: AiRole.system, content: systemPrompt),
      AiMessage(role: AiRole.user, content: userContent),
    ];
  }

  List<AiMessage> queryExpansionPrompt({required String query}) {
    return [
      AiMessage(
        role: AiRole.system,
        content:
            'Expand this query into 3-5 English search keywords. Output ONLY a JSON array of strings.',
      ),
      AiMessage(role: AiRole.user, content: query),
    ];
  }

  List<AiMessage> documentSummaryPrompt({
    required String text,
    required int pageStart,
    required int pageEnd,
  }) {
    return [
      AiMessage(
        role: AiRole.system,
        content:
            'Summarize the provided document chunk covering pages $pageStart to $pageEnd.',
      ),
      AiMessage(role: AiRole.user, content: text),
    ];
  }

  List<AiMessage> meetingSummaryPrompt({required String transcript}) {
    return [
      AiMessage(
        role: AiRole.system,
        content:
            'Extract a meeting summary, action items, and attendees from the provided meeting transcript.',
      ),
      AiMessage(role: AiRole.user, content: transcript),
    ];
  }

  List<AiMessage> journalReflectionPrompt({
    required String notes,
    required DateTime weekStart,
  }) {
    return [
      AiMessage(
        role: AiRole.system,
        content:
            'Review the weekly journal notes starting from $weekStart and extract key reflections and moods.',
      ),
      AiMessage(role: AiRole.user, content: notes),
    ];
  }
}
