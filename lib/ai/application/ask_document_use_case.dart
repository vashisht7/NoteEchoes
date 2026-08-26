// ask_document_use_case.dart
// Grounded document Q&A — retrieves relevant passages, builds a
// citation-rich context, and returns a GroundedResponse.

import '../providers/retrieval_provider.dart';
import '../infrastructure/ai_database.dart';
import '../domain/source_citation.dart';
import '../domain/document_chunk.dart';

class AskDocumentUseCase {
  final RetrievalProvider retrieval;
  final AiDatabase database;

  AskDocumentUseCase(this.retrieval, this.database);

  Future<GroundedResponse> ask(String question, String documentId) async {
    // 1. Retrieve relevant passages
    var passages = await retrieval.search(
      question,
      filterSourceId: documentId,
      maxResults: 7,
    );

    // Broad prompts such as "summarize this PDF" contain few document terms.
    // Fall back to the document's opening chunks instead of returning nothing.
    if (passages.isEmpty) {
      final chunks = await database.getChunksForDocument(documentId);
      passages = chunks.take(7).map((chunk) {
        return RetrievedPassage(
          sourceId: chunk.id,
          sourceType: 'document_chunk',
          text: chunk.originalText,
          englishRetrievalText: chunk.englishRetrievalText,
          score: chunk.sourceOrder.toDouble(),
          pageStart: chunk.pageStart,
          pageEnd: chunk.pageEnd,
          sourceTitle: 'PDF',
        );
      }).toList();
    }

    if (passages.isEmpty) {
      const message =
          'No readable passages were indexed for this PDF. Open Clean Text to check whether OCR could read it.';
      return const GroundedResponse(
        rawText: message,
        displayText: message,
        citations: {},
      );
    }

    // 2. Build numbered context block
    final ctx = StringBuffer();
    for (var i = 0; i < passages.length; i++) {
      ctx.writeln('[S${i + 1}] ${passages[i].text}');
    }

    // The installed model is an action-routing model, not a general document
    // chat model. Return relevant source passages directly rather than asking
    // it to synthesize unsupported prose or action-schema JSON.
    final rawText = StringBuffer('Relevant passages from this PDF:\n\n');
    final citationsMap = <String, SourceCitation>{};
    for (var index = 0; index < passages.length; index++) {
      final passage = passages[index];
      final key = 'S${index + 1}';
      final excerpt = _excerpt(passage.text);
      rawText.writeln('${index + 1}. $excerpt [$key]\n');
      citationsMap[key] = SourceCitation(
        citationKey: key,
        sourceId: passage.sourceId,
        sourceTitle: passage.sourceTitle ?? 'PDF',
        quotedEvidence: excerpt,
        pageStart: passage.pageStart,
        pageEnd: passage.pageEnd,
      );
    }

    final raw = rawText.toString().trim();
    final displayText = raw.replaceAll(RegExp(r'\s*\[S\d+\]'), '').trim();

    return GroundedResponse(
      rawText: raw,
      displayText: displayText,
      citations: citationsMap,
    );
  }

  static String _excerpt(String value) {
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 420) return compact;
    final sentenceEnd = compact.lastIndexOf(RegExp(r'[.!?।]'), 420);
    final cut = sentenceEnd >= 120 ? sentenceEnd + 1 : 420;
    return '${compact.substring(0, cut).trimRight()}…';
  }
}
