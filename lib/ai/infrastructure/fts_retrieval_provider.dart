import 'dart:convert';
import '../providers/retrieval_provider.dart';
import '../providers/text_generation_provider.dart';
import '../domain/document_chunk.dart';
import '../domain/ai_models.dart';
import '../infrastructure/ai_database.dart';

class FtsRetrievalProvider implements RetrievalProvider {
  final AiDatabase database;
  final TextGenerationProvider? llm;

  FtsRetrievalProvider(this.database, {this.llm});

  @override
  Future<void> indexPassages(List<RetrievedPassage> passages) async {
    for (var passage in passages) {
      await database.ftsUpsert(
        sourceId: passage.sourceId,
        sourceType: passage.sourceType,
        title: passage.sourceTitle ?? '',
        originalText: passage.text,
        englishRetrievalText: passage.englishRetrievalText,
      );
    }
  }

  @override
  Future<void> removeSource(String sourceId) async {
    await database.ftsDelete(sourceId);
  }

  @override
  Future<List<RetrievedPassage>> search(
    String query, {
    int maxResults = 7,
    String? filterSourceId,
  }) async {
    String finalQuery = query;
    // 1. Query expansion if LLM is available
    if (llm != null && llm!.isLoaded) {
      try {
        final expanded = await llm!.generate([
          AiMessage(
            role: AiRole.system,
            content:
                'Expand this search query into 3-5 short search terms. '
                'Keep useful terms in the question language and add English '
                'equivalents when helpful. Output ONLY a JSON array of strings.',
          ),
          AiMessage(role: AiRole.user, content: query),
        ]);
        final keywords = jsonDecode(expanded) as List<dynamic>;
        final keywordString = keywords.map((k) => k.toString()).join(' ');
        finalQuery = '$query $keywordString';
      } catch (e) {
        // Fallback to original query on error
      }
    }

    // 2. Sanitize for FTS5
    final terms = finalQuery
        .split(RegExp(r'[\s,;:!?()\[\]{}]+', unicode: true))
        .map((term) => term.trim().replaceAll('"', ''))
        .where((term) => term.isNotEmpty)
        .toSet();
    if (terms.isEmpty) return const [];
    final sanitizedQuery = terms.map((term) => '"$term"').join(' OR ');

    // 3. Search database
    final results = await database.ftsSearch(sanitizedQuery, maxResults * 2);

    // 4. Map results
    var mappedResults = results
        .map(
          (r) => RetrievedPassage(
            sourceId: r['source_id'] as String,
            sourceType: r['source_type'] as String,
            sourceTitle: r['title'] as String?,
            text: r['original_text'] as String,
            englishRetrievalText: r['english_retrieval_text'] as String?,
            score: (r['score'] as num?)?.toDouble() ?? 0.0,
          ),
        )
        .toList();

    if (filterSourceId != null) {
      final chunkIds = (await database.getChunksForDocument(
        filterSourceId,
      )).map((chunk) => chunk.id).toSet();
      mappedResults = mappedResults
          .where(
            (p) =>
                p.sourceId == filterSourceId || chunkIds.contains(p.sourceId),
          )
          .toList();
    }

    // 5. Deduplicate by sourceId, prefer higher score
    final uniqueResults = <String, RetrievedPassage>{};
    for (var result in mappedResults) {
      if (!uniqueResults.containsKey(result.sourceId) ||
          uniqueResults[result.sourceId]!.score > result.score) {
        uniqueResults[result.sourceId] = result;
      }
    }

    // 6. Sort and take maxResults
    var deduplicated = uniqueResults.values.toList();
    // FTS5 bm25 uses lower (usually more-negative) values for better matches.
    deduplicated.sort((a, b) => a.score.compareTo(b.score));

    return deduplicated.take(maxResults).toList();
  }

  @override
  Future<void> rebuildIndex() async {
    // No-op for this implementation (FTS5 is always in sync)
  }
}
