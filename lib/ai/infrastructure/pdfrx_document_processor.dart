import '../domain/document_chunk.dart';
import '../providers/document_processor.dart';

class PdfrxDocumentProcessor implements DocumentProcessor {
  @override
  Future<List<DocumentChunk>> process(
    String filePath,
    ProcessedDocument document, {
    void Function(DocumentProgress progress)? onProgress,
  }) async {
    onProgress?.call(
      DocumentProgress(
        documentId: document.id,
        state: DocumentProcessingState.completed,
        currentPage: 1,
        totalPages: 1,
        message: 'Completed',
      ),
    );

    return [
      DocumentChunk(
        id: 'chunk_1',
        documentId: document.id,
        pageStart: 1,
        pageEnd: 1,
        originalText: 'Stub document text.',
        sourceOrder: 0,
      )
    ];
  }
}
