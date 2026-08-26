// hybrid_retrieval_service.dart
// Hybrid grounded retrieval combining FTS5 lexical, E5 semantic embeddings,
// and 1-hop Knowledge Graph expansion with Reciprocal Rank Fusion (RRF).

import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../config/action_model_identity.dart';
import '../domain/ai_models.dart';
import '../domain/source_citation.dart';
import 'ai_database.dart';
import 'e5_embedding_service.dart';
import 'model_availability_service.dart';
import '../../services/speech_output_service.dart';
import 'structured_generation_service.dart';

class GroundedAnswerResult {
  final String query;
  final String displayText;
  final String speechText;
  final String responseLanguage;
  final List<SourceCitation> citations;
  final List<String> sourceNoteIds;
  final AiProvenance provenance;

  const GroundedAnswerResult({
    required this.query,
    required this.displayText,
    required this.speechText,
    required this.responseLanguage,
    required this.citations,
    required this.sourceNoteIds,
    required this.provenance,
  });
}

class HybridCandidate {
  final String noteId;
  final String title;
  final String passageText;
  final double ftsRank;
  final double semanticRank;
  final double graphRank;
  final double rrfScore;
  final bool isPinned;
  final int updatedAt;

  const HybridCandidate({
    required this.noteId,
    required this.title,
    required this.passageText,
    this.ftsRank = 0.0,
    this.semanticRank = 0.0,
    this.graphRank = 0.0,
    required this.rrfScore,
    this.isPinned = false,
    this.updatedAt = 0,
  });
}

class HybridRetrievalService {
  static const int kRrfConstant = 60;

  static List<double> _decodeVector(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    final count = bytes.length ~/ 4;
    return List<double>.generate(
      count,
      (i) => byteData.getFloat32(i * 4, Endian.little),
    );
  }

  static double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0.0;
    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = sqrt(normA) * sqrt(normB);
    return denom > 0 ? dot / denom : 0.0;
  }

  /// Performs hybrid retrieval and reciprocal rank fusion across FTS5, E5, and Graph.
  static Future<List<HybridCandidate>> retrieveCandidates({
    required String query,
    required AiDatabase database,
    int topK = 6,
  }) async {
    final Map<String, _CandidateAccumulator> candidates = {};

    // 1. FTS5 Lexical Search (Top 15)
    try {
      final ftsMatches = await database.ftsSearch(query, 15);
      for (int i = 0; i < ftsMatches.length; i++) {
        final row = ftsMatches[i];
        final id = row['source_id'] as String? ?? '';
        final title = row['title'] as String? ?? 'Note';
        final text = row['original_text'] as String? ?? '';

        if (id.isNotEmpty) {
          final acc = candidates.putIfAbsent(
            id,
            () => _CandidateAccumulator(id: id, title: title, text: text),
          );
          acc.ftsRank = i + 1;
        }
      }
    } catch (e) {
      debugPrint("[HybridRetrieval] FTS5 search notice: $e");
    }

    // 2. E5 Semantic Embedding Search (Top 15)
    try {
      if (ModelAvailabilityService.instance.embedding.isReady) {
        final queryVector = await E5EmbeddingService.instance.embedQuery(query);
        final allEmbeddings = await database
            .select(database.noteEmbeddingsTable)
            .get();

        final scoredList = <MapEntry<String, double>>[];
        for (final row in allEmbeddings) {
          final rowVector = _decodeVector(row.vector);
          if (rowVector.length == queryVector.length) {
            final sim = _cosineSimilarity(queryVector, rowVector);
            scoredList.add(MapEntry(row.noteId, sim));
          }
        }
        scoredList.sort((a, b) => b.value.compareTo(a.value));

        final topE5 = scoredList.take(15).toList();
        for (int i = 0; i < topE5.length; i++) {
          final id = topE5[i].key;
          final acc = candidates.putIfAbsent(
            id,
            () => _CandidateAccumulator(id: id, title: 'Note', text: ''),
          );
          acc.semanticRank = i + 1;
        }
      }
    } catch (e) {
      debugPrint("[HybridRetrieval] E5 semantic notice: $e");
    }

    // 3. 1-Hop Knowledge Graph Expansion
    try {
      final topIds = candidates.keys.take(5).toList();
      for (final rootId in topIds) {
        final neighbors =
            await (database.select(database.noteRelationshipsTable)..where(
                  (t) =>
                      t.sourceNoteId.equals(rootId) &
                      t.status.isNotIn(const ['dismissed']),
                ))
                .get();

        for (final row in neighbors) {
          final neighborId = row.targetNoteId;
          final acc = candidates.putIfAbsent(
            neighborId,
            () => _CandidateAccumulator(
              id: neighborId,
              title: 'Related Note',
              text: '',
            ),
          );
          acc.isGraphExpanded = true;
        }
      }
    } catch (e) {
      debugPrint("[HybridRetrieval] Graph expansion notice: $e");
    }

    // 4. Calculate Reciprocal Rank Fusion Scores
    final results = <HybridCandidate>[];
    for (final acc in candidates.values) {
      double rrf = 0.0;
      if (acc.ftsRank > 0) {
        rrf += 1.0 / (kRrfConstant + acc.ftsRank);
      }
      if (acc.semanticRank > 0) {
        rrf += 1.0 / (kRrfConstant + acc.semanticRank);
      }
      if (acc.isGraphExpanded) {
        rrf += 0.005; // 1-hop relation boost
      }

      results.add(
        HybridCandidate(
          noteId: acc.id,
          title: acc.title,
          passageText: acc.text,
          ftsRank: acc.ftsRank.toDouble(),
          semanticRank: acc.semanticRank.toDouble(),
          rrfScore: rrf,
        ),
      );
    }

    // Sort by descending RRF score
    results.sort((a, b) => b.rrfScore.compareTo(a.rrfScore));
    return results.take(topK).toList();
  }

  /// Generates a grounded, cited answer in the user query's language.
  static Future<GroundedAnswerResult> answerQuery({
    required String query,
    required List<HybridCandidate> candidates,
    required String queryLanguage,
  }) async {
    final citations = <SourceCitation>[];
    final noteIds = <String>[];

    final contextBuffer = StringBuffer();
    for (int i = 0; i < candidates.length; i++) {
      final c = candidates[i];
      final idx = i + 1;
      contextBuffer.writeln(
        '[$idx] Note Title: "${c.title}"\nContent: ${c.passageText}\n',
      );
      citations.add(
        SourceCitation(
          citationKey: '[$idx]',
          sourceId: c.noteId,
          sourceTitle: c.title,
          quotedEvidence: c.passageText,
          noteId: c.noteId,
        ),
      );
      noteIds.add(c.noteId);
    }

    if (candidates.isEmpty) {
      final noNotesText = queryLanguage == 'te'
          ? 'మీ నోట్స్ లో ఈ విషయానికి సంబంధించిన సమాచారం దొరకలేదు.'
          : (queryLanguage == 'hi'
                ? 'आपके नोट्स में इस विषय से संबंधित जानकारी नहीं मिली।'
                : 'I could not find any notes matching your question.');
      return GroundedAnswerResult(
        query: query,
        displayText: noNotesText,
        speechText: noNotesText,
        responseLanguage: queryLanguage,
        citations: const [],
        sourceNoteIds: const [],
        provenance: AiProvenance(
          modelId: 'retrieval_empty_fallback',
          modelVersion: '1.0',
          promptVersion: '1.0',
          schemaVersion: 1,
          confidence: 1.0,
          rawOutput: noNotesText,
        ),
      );
    }

    // The deployed Qwen model is deliberately specialized for the English
    // action schema. Asking it to behave as an unrestricted chat summarizer
    // produces action JSON instead of a readable report. Conversation mode
    // therefore uses a deterministic, cited extractive report. This keeps the
    // output useful, private, and strictly grounded in saved note text.
    if (_isSummaryRequest(query)) {
      return _extractiveReport(
        query: query,
        candidates: candidates,
        citations: citations,
        noteIds: noteIds,
        queryLanguage: queryLanguage,
      );
    }

    // Generate grounded synthesis with Qwen MLX if ready
    if (ModelAvailabilityService.instance.qwen.isReady) {
      try {
        final langInstruction = switch (queryLanguage) {
          'te' => 'Respond in natural Telugu script.',
          'hi' => 'Respond in natural Hindi script.',
          'mixed' =>
            'Respond in conversational Telugu and English code-mixed style.',
          _ => 'Respond in clear English.',
        };

        final systemPrompt =
            '''
You are the NoteEchoes grounded conversational AI assistant.
Answer the user's question STRICTLY based on the provided notes.
$langInstruction
Rules:
1. Cite every factual claim using bracket numbers like [1] or [2].
2. If the answer is not in the notes, say so honestly without inventing facts.
3. Keep the response concise, informative, and natural.
''';

        final userPrompt =
            '''
User Question: "$query"

Retrieved Notes Context:
$contextBuffer

Grounded Answer:''';

        final response =
            await StructuredGenerationService.generateStructured<String>(
              prompt: userPrompt,
              systemPrompt: systemPrompt,
              fromJson: (json) => json['answer'] as String? ?? '',
              modelId: NoteEchoesActionModelIdentity.modelId,
              modelVersion: NoteEchoesActionModelIdentity.releaseVersion,
              promptVersion: '1.0',
              schemaVersion: 1,
            );

        final answerText = response.isSuccess
            ? response.value?.trim() ?? ''
            : '';

        if (answerText.isNotEmpty) {
          final speechText = SpeechOutputService.cleanSpeechText(answerText);
          return GroundedAnswerResult(
            query: query,
            displayText: answerText,
            speechText: speechText,
            responseLanguage: queryLanguage,
            citations: citations,
            sourceNoteIds: noteIds,
            provenance: response.provenance,
          );
        }
      } catch (e) {
        debugPrint("[HybridRetrieval] Qwen grounded synthesis notice: $e");
      }
    }

    return _extractiveReport(
      query: query,
      candidates: candidates,
      citations: citations,
      noteIds: noteIds,
      queryLanguage: queryLanguage,
    );
  }

  static bool _isSummaryRequest(String query) => RegExp(
    r'\b(?:summari[sz]e|summary|overview|recap|discuss|review)\b|'
    r'(?:సారాంశం|సంగ్రహించు|నోట్స్\s+చెప్పు)|'
    r'(?:सारांश|संक्षेप|नोट्स\s+बताओ)',
    caseSensitive: false,
  ).hasMatch(query);

  static GroundedAnswerResult _extractiveReport({
    required String query,
    required List<HybridCandidate> candidates,
    required List<SourceCitation> citations,
    required List<String> noteIds,
    required String queryLanguage,
  }) {
    final heading = switch (queryLanguage) {
      'te' => 'మీ నోట్స్ ఆధారంగా:',
      'hi' => 'आपके नोट्स के आधार पर:',
      _ => 'Based on your saved notes:',
    };
    final lines = <String>[heading];
    for (var index = 0; index < candidates.length; index++) {
      final candidate = candidates[index];
      final excerpt = _conciseExcerpt(candidate.passageText);
      lines.add(
        excerpt.isEmpty
            ? '${index + 1}. ${candidate.title} [${index + 1}]'
            : '${index + 1}. ${candidate.title}: $excerpt [${index + 1}]',
      );
    }
    final report = lines.join('\n\n');
    return GroundedAnswerResult(
      query: query,
      displayText: report,
      speechText: SpeechOutputService.cleanSpeechText(report),
      responseLanguage: queryLanguage,
      citations: citations,
      sourceNoteIds: noteIds,
      provenance: AiProvenance(
        modelId: 'deterministic_grounded_extractive_report',
        modelVersion: '1.0',
        promptVersion: '1.0',
        schemaVersion: 1,
        confidence: 1.0,
        rawOutput: report,
      ),
    );
  }

  static String _conciseExcerpt(String value) {
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) return '';
    const maximum = 260;
    if (compact.length <= maximum) return compact;
    final sentenceEnd = compact.lastIndexOf(RegExp(r'[.!?।]'), maximum);
    final cut = sentenceEnd >= 80 ? sentenceEnd + 1 : maximum;
    return '${compact.substring(0, cut).trimRight()}…';
  }
}

class _CandidateAccumulator {
  final String id;
  final String title;
  final String text;
  int ftsRank = 0;
  int semanticRank = 0;
  bool isGraphExpanded = false;

  _CandidateAccumulator({
    required this.id,
    required this.title,
    required this.text,
  });
}
