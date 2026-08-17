import '../../models/note_model.dart';

enum SemanticSuggestionStatus { suggested, confirmed, dismissed }

class RelatedNote {
  final NoteModel note;
  final double similarity;
  final SemanticSuggestionStatus status;
  final String explanation;

  const RelatedNote({
    required this.note,
    required this.similarity,
    required this.status,
    required this.explanation,
  });
}

class NoteTopic {
  final String id;
  final String label;
  final String summary;
  final SemanticSuggestionStatus status;
  final List<NoteModel> notes;
  final double confidence;

  const NoteTopic({
    required this.id,
    required this.label,
    required this.summary,
    required this.status,
    required this.notes,
    required this.confidence,
  });
}
