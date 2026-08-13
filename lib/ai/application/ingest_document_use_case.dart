// ingest_document_use_case.dart
// Coordinates PDF import, text extraction, chunking, and FTS indexing.

import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../providers/document_processor.dart';
import '../providers/text_generation_provider.dart';
import '../infrastructure/ai_database.dart';
import '../domain/document_chunk.dart';
import '../config/ai_feature_flags.dart';

class IngestDocumentUseCase {
  final DocumentProcessor processor;
  final AiDatabase database;
  final TextGenerationProvider? llm;

  IngestDocumentUseCase(this.processor, this.database, {this.llm});

  Future<ProcessedDocument> execute(
    String pdfFilePath, {
    String? notebookId,
    void Function(DocumentProgress)? onProgress,
  }) async {
    final file = File(pdfFilePath);
    final bytes = await file.readAsBytes();
    final fileHash = sha256.convert(bytes).toString();
    final fileName = pdfFilePath.split('/').last;

    // Check if already imported by SHA-256
    final existing = await database.getAllDocuments().then((docs) {
      try {
        return docs.firstWhere((d) => d.sha256 == fileHash);
      } catch (_) {
        return null;
      }
    });

    if (existing != null) {
      return _rowToDocument(existing);
    }

    if (!AiFeatureFlags.instance.pdfIngestionEnabled) {
      throw Exception(
          'PDF ingestion is disabled. Enable it from Settings → AI Models.');
    }

    final documentId = const Uuid().v4();
    final now = DateTime.now();

    // Create document record
    await database.upsertDocument(
      DocumentsTableCompanion(
        id: Value(documentId),
        notebookId: Value(notebookId),
        localPath: Value(pdfFilePath),
        sha256: Value(fileHash),
        title: Value(fileName.replaceAll('.pdf', '')),
        processingState:
            Value(DocumentProcessingState.pending.jsonKey),
        importedAt: Value(now.millisecondsSinceEpoch),
      ),
    );

    // Update to extracting state
    await database.updateDocumentState(
        documentId, DocumentProcessingState.extractingText.jsonKey);

    final document = ProcessedDocument(
      id: documentId,
      notebookId: notebookId,
      localPath: pdfFilePath,
      sha256: fileHash,
      title: fileName.replaceAll('.pdf', ''),
      processingState: DocumentProcessingState.extractingText,
      importedAt: now,
    );

    try {
      // Extract and chunk
      final chunks =
          await processor.process(pdfFilePath, document, onProgress: onProgress);

      await database.updateDocumentState(
          documentId, DocumentProcessingState.indexing.jsonKey);

      // Index each chunk
      for (final chunk in chunks) {
        await database.insertChunk(
          DocumentChunksTableCompanion(
            id: Value(chunk.id),
            documentId: Value(chunk.documentId),
            pageStart: Value(chunk.pageStart),
            pageEnd: Value(chunk.pageEnd),
            chapter: Value(chunk.chapter),
            originalText: Value(chunk.originalText),
            englishRetrievalText: Value(chunk.englishRetrievalText),
            keywords: Value(chunk.keywords.join(' ')),
            tokenEstimate: Value(chunk.tokenEstimate),
            sourceOrder: Value(chunk.sourceOrder),
          ),
        );

        await database.ftsUpsert(
          sourceId: chunk.id,
          sourceType: 'document_chunk',
          title: document.title,
          originalText: chunk.originalText,
          englishRetrievalText: chunk.englishRetrievalText,
          keywords: chunk.keywords.join(' '),
        );
      }

      await database.updateDocumentState(
          documentId, DocumentProcessingState.completed.jsonKey);

      return document.copyWith(
          processingState: DocumentProcessingState.completed);
    } catch (e) {
      await database.updateDocumentState(
          documentId, DocumentProcessingState.failed.jsonKey, e.toString());
      rethrow;
    }
  }

  ProcessedDocument _rowToDocument(DocumentsTableData row) {
    return ProcessedDocument(
      id: row.id,
      notebookId: row.notebookId,
      localPath: row.localPath,
      sha256: row.sha256,
      title: row.title,
      pageCount: row.pageCount,
      processingState: DocumentProcessingStateExt.fromString(row.processingState),
      processingError: row.processingError,
      importedAt: DateTime.fromMillisecondsSinceEpoch(row.importedAt),
    );
  }
}
