// suggested_action.dart
// Domain types for suggested AI actions derived from note analysis.

enum SuggestedActionType {
  actionItem,
  calendarEvent,
  reminder,
  travelDetail,
}

enum SuggestedActionStatus {
  pending,     // awaiting user review
  confirmed,   // user confirmed — platform write succeeded
  dismissed,   // user dismissed
  failed,      // platform write failed
}

/// A suggested action extracted from a note, awaiting user confirmation.
class SuggestedAction {
  final String id;
  final String noteId;
  final SuggestedActionType actionType;
  final String title;
  final Map<String, dynamic> details;
  final String evidenceText;
  final int? sourceStartMs;
  final int? sourceEndMs;
  final int? sourcePage;
  final double confidence;
  final SuggestedActionStatus status;
  final DateTime createdAt;

  const SuggestedAction({
    required this.id,
    required this.noteId,
    required this.actionType,
    required this.title,
    required this.details,
    required this.evidenceText,
    this.sourceStartMs,
    this.sourceEndMs,
    this.sourcePage,
    required this.confidence,
    this.status = SuggestedActionStatus.pending,
    required this.createdAt,
  });

  SuggestedAction copyWith({
    SuggestedActionStatus? status,
  }) {
    return SuggestedAction(
      id: id,
      noteId: noteId,
      actionType: actionType,
      title: title,
      details: details,
      evidenceText: evidenceText,
      sourceStartMs: sourceStartMs,
      sourceEndMs: sourceEndMs,
      sourcePage: sourcePage,
      confidence: confidence,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
