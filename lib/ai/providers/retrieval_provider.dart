// retrieval_provider.dart
// Abstract interface for FTS5-based cross-language retrieval.

import '../domain/document_chunk.dart';

/// Abstract interface for hybrid FTS5 + BM25 retrieval.
abstract class RetrievalProvider {
  /// Add or update indexed passages.
  Future<void> indexPassages(List<RetrievedPassage> passages);

  /// Remove all passages for a given source.
  Future<void> removeSource(String sourceId);

  /// Search with query expansion and BM25 ranking.
  ///
  /// [query] is in any supported language; the provider translates
  /// internally to English retrieval terms via the LLM before querying.
  ///
  /// Returns ranked [RetrievedPassage]s sorted by relevance.
  Future<List<RetrievedPassage>> search(
    String query, {
    int maxResults = 7,
    String? filterSourceId,
  });

  /// Re-index all stored content. Useful after schema updates.
  Future<void> rebuildIndex();
}
