import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/application/ask_document_use_case.dart';
import 'package:notechoes_app/ai/domain/document_chunk.dart';
import 'package:notechoes_app/ai/infrastructure/ai_database.dart';
import 'package:notechoes_app/ai/providers/retrieval_provider.dart';

class _FixedRetrieval implements RetrievalProvider {
  @override
  Future<List<RetrievedPassage>> search(
    String query, {
    int maxResults = 7,
    String? filterSourceId,
  }) async => const [
    RetrievedPassage(
      sourceId: 'chunk-1',
      sourceType: 'document_chunk',
      text: 'The release requires device testing before publication.',
      score: 0,
      pageStart: 3,
      pageEnd: 3,
      sourceTitle: 'Release guide',
    ),
  ];

  @override
  Future<void> indexPassages(List<RetrievedPassage> passages) async {}

  @override
  Future<void> rebuildIndex() async {}

  @override
  Future<void> removeSource(String sourceId) async {}
}

void main() {
  test('PDF questions return grounded passages with page citations', () async {
    final database = AiDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final response = await AskDocumentUseCase(
      _FixedRetrieval(),
      database,
    ).ask('What is required before publication?', 'document-1');

    expect(response.displayText, contains('device testing'));
    expect(response.rawText, contains('[S1]'));
    expect(response.citations['S1']?.pageStart, 3);
    expect(response.citations['S1']?.quotedEvidence, contains('publication'));
  });
}
