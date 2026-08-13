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
  Future<List<RetrievedPassage>> search(String query, {int maxResults = 7, String? filterSourceId}) async {
    String finalQuery = query;
    // 1. Query expansion if LLM is available
    if (llm != null && llm!.isLoaded) {
      try {
        final expanded = await llm!.generate([
          AiMessage(
            role: AiRole.system,
            content: 'Expand this search query into 3-5 English keywords. Output ONLY a JSON array of strings.',
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
    final sanitizedQuery = '"${finalQuery.replaceAll('"', '\\"')}"';

    // 3. Search database
    final results = await database.ftsSearch(sanitizedQuery, maxResults * 2);

    // 4. Map results
    var mappedResults = results.map((r) => RetrievedPassage(
      sourceId: r['sourceId'] as String,
      sourceType: r['sourceType'] as String,
      sourceTitle: r['title'] as String?,
      text: r['originalText'] as String,
      englishRetrievalText: r['englishRetrievalText'] as String?,
      score: (r['score'] as num?)?.toDouble() ?? 0.0,
    )).toList();

    if (filterSourceId != null) {
      mappedResults = mappedResults.where((p) => p.sourceId == filterSourceId).toList();
    }

    // 5. Deduplicate by sourceId, prefer higher score
    final uniqueResults = <String, RetrievedPassage>{};
    for (var result in mappedResults) {
      if (!uniqueResults.containsKey(result.sourceId) || uniqueResults[result.sourceId]!.score < result.score) {
        uniqueResults[result.sourceId] = result;
      }
    }

    // 6. Sort and take maxResults
    var deduplicated = uniqueResults.values.toList();
    deduplicated.sort((a, b) => b.score.compareTo(a.score));

    return deduplicated.take(maxResults).toList();
  }

  @override
  Future<void> rebuildIndex() async {
    // No-op for this implementation (FTS5 is always in sync)
  }
}
