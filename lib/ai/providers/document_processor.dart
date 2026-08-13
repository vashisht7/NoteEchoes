// document_processor.dart
// Abstract interface for PDF text extraction and chunking.

import '../domain/document_chunk.dart';

/// Abstract interface for document (PDF) text extraction.
abstract class DocumentProcessor {
  /// Process a document at [filePath].
  ///
  /// Emits progress via [onProgress].
  /// Returns the list of produced [DocumentChunk]s.
  ///
  /// The implementation is expected to:
  ///  1. Extract text page-by-page (never fully loading into RAM).
  ///  2. Detect scanned pages and use OCR.
  ///  3. Split into 350–600 token chunks with 50–80 token overlap.
  ///  4. Prefer paragraph/heading boundaries.
  ///  5. Persist each chunk after processing (crash-safe).
  Future<List<DocumentChunk>> process(
    String filePath,
    ProcessedDocument document, {
    void Function(DocumentProgress progress)? onProgress,
  });
}
