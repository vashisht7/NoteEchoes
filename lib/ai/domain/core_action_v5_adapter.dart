import 'core_action_v5.dart';
import 'note_analysis.dart';

/// Maps the validated English Core v5 action envelope into the note UI's
/// existing analysis model. Tool proposals remain data only; this adapter does
/// not execute reminders, messages, calendar events, or any other side effect.
class CoreActionV5Adapter {
  static NoteAnalysisResult toNoteAnalysis(
    CoreV5Envelope envelope, {
    required String noteContent,
    required String noteId,
    required String modelVersion,
    required DateTime analysedAt,
  }) {
    final actionItems = <ActionItem>[];
    if ({'task', 'checklist'}.contains(envelope.intent)) {
      for (var index = 0; index < envelope.items.length; index++) {
        final text = envelope.items[index].text;
        actionItems.add(
          ActionItem(
            id: '$noteId-task-$index',
            task: text,
            confidence: envelope.confidence,
            evidenceText: text,
          ),
        );
      }
    }

    final normalized = envelope.normalizedText.trim();
    final title = envelope.title?.trim().isNotEmpty == true
        ? envelope.title!.trim()
        : _safeTitle(normalized.isEmpty ? noteContent : normalized);
    final summary = envelope.draft?.trim().isNotEmpty == true
        ? envelope.draft!.trim()
        : (normalized.isEmpty ? noteContent.trim() : normalized);
    final tag = envelope.intent;

    return NoteAnalysisResult(
      noteId: noteId,
      modelVersion: modelVersion,
      detectedLanguage: envelope.language,
      noteType: _noteType(envelope.intent, actionItems),
      generatedTitle: title,
      summary: summary,
      englishRetrievalSummary: summary,
      topics: _isControlOrQuery(tag) ? const [] : [tag],
      people: envelope.entities.people,
      places: envelope.entities.place == null
          ? const []
          : [envelope.entities.place!],
      suggestedTags: _isControlOrQuery(tag) ? const [] : [tag],
      actionItems: actionItems,
      // Reminder/calendar/message/email outputs are proposals. Execution is
      // intentionally left to confirmed providers outside model inference.
      events: const [],
      reminders: const [],
      travelDetails: const [],
      analysedAt: analysedAt,
    );
  }

  static bool _isControlOrQuery(String intent) =>
      {'cancel', 'clarify', 'noop', 'memory_query'}.contains(intent);

  static NoteType _noteType(String intent, List<ActionItem> actionItems) {
    if (actionItems.isNotEmpty || {'task', 'checklist'}.contains(intent)) {
      return NoteType.actionList;
    }
    if (intent == 'reminder') return NoteType.reminder;
    if (intent == 'idea') return NoteType.brainstorm;
    if (intent == 'calendar') return NoteType.meeting;
    return NoteType.general;
  }

  static String _safeTitle(String value) {
    final compact = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (compact.isEmpty) return 'Untitled Note';
    if (compact.length <= 96) return compact;
    return '${compact.substring(0, 95).trimRight()}…';
  }
}
