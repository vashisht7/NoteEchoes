// document_chunk.dart
// Typed data classes for PDF and document ingestion and retrieval.

/// Processing state of a document.
enum DocumentProcessingState {
  pending,
  extractingText,
  chunking,
  indexing,
  completed,
  failed,
}

extension DocumentProcessingStateExt on DocumentProcessingState {
  String get jsonKey => name;

  static DocumentProcessingState fromString(String? s) {
    switch (s) {
      case 'pending':
        return DocumentProcessingState.pending;
      case 'extractingText':
      case 'extracting_text':
        return DocumentProcessingState.extractingText;
      case 'chunking':
        return DocumentProcessingState.chunking;
      case 'indexing':
        return DocumentProcessingState.indexing;
      case 'completed':
        return DocumentProcessingState.completed;
      case 'failed':
        return DocumentProcessingState.failed;
      default:
        return DocumentProcessingState.pending;
    }
  }
}

/// Metadata for an imported document.
class ProcessedDocument {
  final String id;
  final String? notebookId;
  final String localPath;
  final String sha256;
  final String title;
  final int? pageCount;
  final DocumentProcessingState processingState;
  final String? processingError;
  final DateTime importedAt;

  const ProcessedDocument({
    required this.id,
    this.notebookId,
    required this.localPath,
    required this.sha256,
    required this.title,
    this.pageCount,
    this.processingState = DocumentProcessingState.pending,
    this.processingError,
    required this.importedAt,
  });

  ProcessedDocument copyWith({
    String? id,
    String? notebookId,
    String? localPath,
    String? sha256,
    String? title,
    int? pageCount,
    DocumentProcessingState? processingState,
    String? processingError,
    DateTime? importedAt,
  }) {
    return ProcessedDocument(
      id: id ?? this.id,
      notebookId: notebookId ?? this.notebookId,
      localPath: localPath ?? this.localPath,
      sha256: sha256 ?? this.sha256,
      title: title ?? this.title,
      pageCount: pageCount ?? this.pageCount,
      processingState: processingState ?? this.processingState,
      processingError: processingError ?? this.processingError,
      importedAt: importedAt ?? this.importedAt,
    );
  }

}

/// One semantic text chunk from a document page range.
class DocumentChunk {
  final String id;
  final String documentId;
  final int pageStart;
  final int pageEnd;
  final String? chapter;
  final String originalText;
  final String? englishRetrievalText;
  final List<String> keywords;
  final int? tokenEstimate;
  final int sourceOrder;

  const DocumentChunk({
    required this.id,
    required this.documentId,
    required this.pageStart,
    required this.pageEnd,
    this.chapter,
    required this.originalText,
    this.englishRetrievalText,
    this.keywords = const [],
    this.tokenEstimate,
    required this.sourceOrder,
  });
}

/// A passage retrieved from the FTS5 index.
class RetrievedPassage {
  final String sourceId;
  final String sourceType; // 'note' | 'document_chunk' | 'transcript_segment'
  final String text;
  final String? englishRetrievalText;
  final double score;
  final int? pageStart;
  final int? pageEnd;
  final int? startMs;
  final int? endMs;
  final String? sourceTitle;

  const RetrievedPassage({
    required this.sourceId,
    required this.sourceType,
    required this.text,
    this.englishRetrievalText,
    required this.score,
    this.pageStart,
    this.pageEnd,
    this.startMs,
    this.endMs,
    this.sourceTitle,
  });
}

/// Progress update emitted by the document processor.
class DocumentProgress {
  final String documentId;
  final DocumentProcessingState state;
  final int? currentPage;
  final int? totalPages;
  final String message;

  const DocumentProgress({
    required this.documentId,
    required this.state,
    this.currentPage,
    this.totalPages,
    this.message = '',
  });

  double get fraction {
    if (totalPages == null || totalPages == 0) return 0.0;
    return (currentPage ?? 0) / totalPages!;
  }
}
