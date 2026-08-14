import '../../models/note_model.dart';
import '../application/ask_document_use_case.dart';
import '../application/ask_notebook_use_case.dart';
import '../application/ingest_document_use_case.dart';
import '../domain/document_chunk.dart';
import '../domain/source_citation.dart';
import 'ai_database.dart';
import 'fts_retrieval_provider.dart';
import 'pdfrx_document_processor.dart';
import 'qwen_llama_provider.dart';

/// Single owner for the local knowledge database and MLX-backed grounded Q&A.
class KnowledgeService {
  KnowledgeService._()
    : database = AiDatabase(),
      llm = QwenLlamaProvider.instance {
    retrieval = FtsRetrievalProvider(database, llm: llm);
  }

  static final KnowledgeService instance = KnowledgeService._();

  final AiDatabase database;
  final QwenLlamaProvider llm;
  late final FtsRetrievalProvider retrieval;

  Future<void> indexNote(NoteModel note) => database.ftsUpsert(
    sourceId: note.noteId,
    sourceType: 'note',
    title: note.title,
    originalText: note.textContent,
    keywords: note.tags.join(' '),
  );

  Future<void> removeNote(String noteId) => database.ftsDelete(noteId);

  Future<ProcessedDocument> ingestPdf(
    String filePath, {
    void Function(DocumentProgress)? onProgress,
  }) => IngestDocumentUseCase(
    PdfrxDocumentProcessor(),
    database,
    llm: llm,
  ).execute(filePath, onProgress: onProgress);

  Future<GroundedResponse> askNotes(String question) async {
    if (!llm.isLoaded) await llm.load();
    return AskNotebookUseCase(llm, retrieval, database).ask(question);
  }

  Future<GroundedResponse> askDocument(
    String question,
    String documentId,
  ) async {
    if (!llm.isLoaded) await llm.load();
    return AskDocumentUseCase(
      llm,
      retrieval,
      database,
    ).ask(question, documentId);
  }
}
