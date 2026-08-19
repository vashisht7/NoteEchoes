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

    // 3. Detect the language of the user's question so the LLM can respond
    //    in the same language (Telugu, Hindi, English, or mixed).
    final langHint = _detectLanguageHint(question);

    // 4. Build messages with multilingual instruction
    final messages = [
      AiMessage(
        role: AiRole.system,
        content: 'You are a multilingual personal notes assistant. '
            'You can understand and respond in Telugu (తెలుగు), Hindi (हिन्दी), '
            'and English. The user\'s notes may be in any of these languages.\n\n'
            '$langHint\n\n'
            'Rules:\n'
            '- Answer using ONLY the provided sources.\n'
            '- Cite every claim with [S1][S2] markers.\n'
            '- If the note content is in a different language than the question, '
            'translate the relevant parts and include both in your answer.\n'
            '- If the answer is not in the sources, say so in the user\'s language.\n\n'
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

  /// Detects the primary script used in [question] and returns an instruction
  /// telling the LLM which language to respond in.
  String _detectLanguageHint(String question) {
    // Telugu Unicode block: U+0C00–U+0C7F
    final teluguChars = RegExp(r'[\u0C00-\u0C7F]');
    // Devanagari block (Hindi): U+0900–U+097F
    final hindiChars = RegExp(r'[\u0900-\u097F]');

    final teluguCount = teluguChars.allMatches(question).length;
    final hindiCount = hindiChars.allMatches(question).length;
    final totalLen = question.length;

    if (teluguCount > 0 && teluguCount / totalLen > 0.1) {
      return 'The user is asking in Telugu. Respond PRIMARILY in Telugu (తెలుగు). '
          'If note content is in English, translate the key facts into Telugu in your answer. '
          'You may include English terms in parentheses for clarity.';
    } else if (hindiCount > 0 && hindiCount / totalLen > 0.1) {
      return 'The user is asking in Hindi. Respond PRIMARILY in Hindi (हिन्दी). '
          'If note content is in English or Telugu, translate the key facts into Hindi. '
          'You may include English terms in parentheses for clarity.';
    } else {
      return 'The user is asking in English. Respond in English. '
          'If notes contain Telugu or Hindi content, include an English translation '
          'of the relevant parts in your answer.';
    }
  }
}
