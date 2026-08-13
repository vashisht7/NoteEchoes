// ask_notebook_use_case.dart
// Cross-note / notebook Q&A with grounded citations.

import '../providers/retrieval_provider.dart';
import '../providers/text_generation_provider.dart';
import '../infrastructure/ai_database.dart';
import '../domain/source_citation.dart';
import '../domain/ai_models.dart';

class AskNotebookUseCase {
  final TextGenerationProvider llm;
  final RetrievalProvider retrieval;
  final AiDatabase database;

  AskNotebookUseCase(this.llm, this.retrieval, this.database);

  Future<GroundedResponse> ask(
    String question, {
    String? notebookId,
    RetrievalScope scope = RetrievalScope.allNotes,
  }) async {
    // 1. Retrieve passages — filter by notebookId only for notebook scope.
    final passages = await retrieval.search(
      question,
      filterSourceId:
          scope == RetrievalScope.notebook ? notebookId : null,
      maxResults: 7,
    );

    // 2. Build numbered context block
    final ctx = StringBuffer();
    for (var i = 0; i < passages.length; i++) {
      ctx.writeln('[S${i + 1}] ${passages[i].text}');
    }

    // 3. Build messages
    final messages = [
      AiMessage(
        role: AiRole.system,
        content: 'You are a helpful assistant answering questions about '
            'the user\'s personal notes. '
            'Answer using ONLY the provided sources. '
            'Cite every claim with [S1][S2] markers. '
            'If the answer is not in the sources, say so.\n\n'
            'Sources:\n$ctx',
      ),
      AiMessage(role: AiRole.user, content: question),
    ];

    // 4. Generate
    final rawText = await llm.generate(messages);

    // 5. Parse citation markers → SourceCitation objects
    final markerRegex = RegExp(r'\[S(\d+)\]');
    final citationsMap = <String, SourceCitation>{};

    for (final match in markerRegex.allMatches(rawText)) {
      final key = match.group(0)!;
      final index = int.tryParse(match.group(1) ?? '');
      if (index != null && index > 0 && index <= passages.length) {
        final passage = passages[index - 1];
        citationsMap[key] = SourceCitation(
          citationKey: 'S$index',
          sourceId: passage.sourceId,
          sourceTitle: passage.sourceTitle ?? passage.sourceId,
          quotedEvidence: passage.text.length > 120
              ? '${passage.text.substring(0, 120)}…'
              : passage.text,
          noteId: passage.sourceType == 'note' ? passage.sourceId : null,
        );
      }
    }

    final displayText = rawText.replaceAll(markerRegex, '').trim();

    return GroundedResponse(
      rawText: rawText,
      displayText: displayText,
      citations: citationsMap,
    );
  }
}
