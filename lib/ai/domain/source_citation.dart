// source_citation.dart
// Citation types linking LLM output markers to source locations.

/// A citation linking an AI response [S1][S2] marker to a specific
/// passage in a note, document page, or audio timestamp.
class SourceCitation {
  final String citationKey; // e.g. "S1"
  final String sourceId;
  final String sourceTitle;
  final String? quotedEvidence;

  // Mutually exclusive location pointers:
  final int? pageStart;
  final int? pageEnd;
  final int? startMs;
  final int? endMs;
  final String? noteId;

  const SourceCitation({
    required this.citationKey,
    required this.sourceId,
    required this.sourceTitle,
    this.quotedEvidence,
    this.pageStart,
    this.pageEnd,
    this.startMs,
    this.endMs,
    this.noteId,
  });

  bool get hasPageLocation => pageStart != null;
  bool get hasAudioLocation => startMs != null;
  bool get hasNoteLocation => noteId != null;

  Map<String, dynamic> toJson() => {
        'citation_key': citationKey,
        'source_id': sourceId,
        'source_title': sourceTitle,
        if (quotedEvidence != null) 'quoted_evidence': quotedEvidence,
        if (pageStart != null) 'page_start': pageStart,
        if (pageEnd != null) 'page_end': pageEnd,
        if (startMs != null) 'start_ms': startMs,
        if (endMs != null) 'end_ms': endMs,
        if (noteId != null) 'note_id': noteId,
      };
}

/// A grounded AI response with inline citation markers resolved to
/// [SourceCitation] objects.
class GroundedResponse {
  /// The raw response text with [S1][S2] markers retained.
  final String rawText;

  /// Response text with markers stripped for display.
  final String displayText;

  /// Map from citationKey ("S1") to SourceCitation.
  final Map<String, SourceCitation> citations;

  const GroundedResponse({
    required this.rawText,
    required this.displayText,
    required this.citations,
  });

  bool get hasGrounding => citations.isNotEmpty;

  List<SourceCitation> get orderedCitations {
    final keys = citations.keys.toList()..sort();
    return keys.map((k) => citations[k]!).toList();
  }
}
