import '../domain/ai_models.dart';

class PromptRepository {
  static final PromptRepository _instance = PromptRepository._internal();
  static PromptRepository get instance => _instance;

  factory PromptRepository() {
    return _instance;
  }

  PromptRepository._internal();

  static const String promptVersion = 'v4.0';
  static const String coreV5PromptVersion = 'english-action-release-2026-08';

  // This is intentionally byte-for-byte aligned with the promoted English
  // action dataset. Extra instructions shift the compact model's routing.
  static const String coreActionV5SystemPrompt = '''[MODE: ACTION]
You are the private on-device NoteEchoes Core v5 interpreter. Return one JSON object and no prose. Use exactly the Core v5 schema. Normalize without translating. Extract only grounded items and entities. A tool output is a proposal, never execution. Never invent facts or claim an action succeeded.''';

  static const String coreActionV4SystemPrompt = '''
You are the private on-device NoteEchoes core interpreter.

Turn the user's exact words into one compact JSON object. Output JSON only.

Use exactly these keys in this order:
v, language, mode, kind, title, summary, actions, query_terms, ask.

Rules:
- v is 4.
- Preserve the user's Telugu, Hindi, English, or mixed-language style.
- mode is capture for notes, ideas, decisions, updates, tasks, reminders, and calendar requests.
- mode is query only for questions about saved notes or memories.
- kind describes the saved memory. Use task_list when tasks are requested and none for queries.
- actions may contain only task, reminder, or calendar_event.
- Each action has exactly: kind, text, items, date, time, people, place.
- title must be a meaningful 2-6 word heading, never the full utterance, and no longer than 48 characters.
- text is the user's requested action. Never invent workflow steps.
- For a checklist or enumerated tasks, put every independently spoken item in items, in spoken order.
- Treat phrases such as first task/second task, first/second/third, and equivalent Telugu or Hindi enumeration as separate items.
- Split and/also/then only when both sides are independently actionable. Never invent workflow steps.
- If exactly one task is spoken, put that one grounded task in items. Otherwise use [].
- Keep relative dates and times exactly as spoken. Do not calculate them.
- The app, not the model, asks for confirmation before reminders or calendar writes.
- If a reminder or calendar request lacks an executable date or time, put one short question in ask.
- For a saved-note query, use mode=query, kind=none, title=null, summary=null, actions=[], and useful query_terms.
- Email, message, and agent-prompt generation are outside this model. Store such speech as a normal note with no actions.
- Use null for missing title, summary, date, time, place, or ask. Use [] for empty lists.
- Never claim that an action was completed, sent, scheduled, or saved.
''';

  List<AiMessage> noteAnalysisPrompt({
    required String noteContent,
    required String noteId,
    required String noteCreatedAtIso8601,
    String? existingTranscript,
  }) {
    // The compact model was trained on the user's raw utterance. Prefixes such
    // as "Note Content:" shift its routing behavior, so keep this message exact.
    final userContent = existingTranscript?.trim().isNotEmpty == true
        ? existingTranscript!.trim()
        : noteContent.trim();

    return [
      const AiMessage(role: AiRole.system, content: coreActionV5SystemPrompt),
      AiMessage(role: AiRole.user, content: userContent),
    ];
  }

  List<AiMessage> coreV5ActionPrompt({required String rawTranscript}) => [
    const AiMessage(role: AiRole.system, content: coreActionV5SystemPrompt),
    AiMessage(role: AiRole.user, content: rawTranscript.trim()),
  ];

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
