import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/domain/source_citation.dart';

void main() {
  group('SourceCitation & GroundedResponse Tests', () {
    test('SourceCitation properties and key formatting', () {
      const citation = SourceCitation(
        citationKey: 'S1',
        sourceId: 'note_123',
        sourceTitle: 'Meeting Notes',
        quotedEvidence: 'Discussion on architecture',
        pageStart: 1,
        pageEnd: 2,
      );

      expect(citation.citationKey, equals('S1'));
      expect(citation.hasPageLocation, isTrue);
      expect(citation.pageStart, equals(1));
      expect(citation.pageEnd, equals(2));

      final json = citation.toJson();
      expect(json['citation_key'], equals('S1'));
      expect(json['source_id'], equals('note_123'));
    });

    test('GroundedResponse correctly parses citations', () {
      const citation1 = SourceCitation(
        citationKey: 'S1',
        sourceId: 'note_1',
        sourceTitle: 'Note 1',
        quotedEvidence: 'Evidence 1',
      );
      const citation2 = SourceCitation(
        citationKey: 'S2',
        sourceId: 'doc_2',
        sourceTitle: 'Doc 2',
        quotedEvidence: 'Evidence 2',
      );

      final response = GroundedResponse(
        rawText:
            'According to [S1] and verified in [S2], the meeting is at 10 AM.',
        displayText: 'According to and verified in , the meeting is at 10 AM.',
        citations: {'S1': citation1, 'S2': citation2},
      );

      expect(response.hasGrounding, isTrue);
      expect(response.orderedCitations.length, equals(2));
      expect(response.orderedCitations.first.citationKey, equals('S1'));
    });
  });
}
