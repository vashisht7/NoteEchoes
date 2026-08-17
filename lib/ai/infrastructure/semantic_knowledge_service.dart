import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../models/note_model.dart';
import '../domain/semantic_models.dart';
import '../domain/ai_models.dart';
import 'ai_database.dart';
import 'e5_embedding_service.dart';
import 'knowledge_service.dart';
import 'model_availability_service.dart';
import 'qwen_llama_provider.dart';

class SemanticKnowledgeService extends ChangeNotifier {
  SemanticKnowledgeService._();
  static final instance = SemanticKnowledgeService._();

  final AiDatabase _database = KnowledgeService.instance.database;
  final E5EmbeddingService _embedder = E5EmbeddingService.instance;
  Future<void> _writeTail = Future<void>.value();
  final Map<String, NoteModel> _knownNotes = {};
  bool _isIndexing = false;
  int _indexed = 0;
  int _total = 0;

  bool get isIndexing => _isIndexing;
  double get progress => _total == 0 ? 0 : _indexed / _total;

  Future<void> indexNote(NoteModel note) {
    final operation = _writeTail.then((_) => _indexNote(note));
    _writeTail = operation.catchError((Object error, StackTrace stack) {
      debugPrint('Semantic indexing failed: $error');
    });
    return operation;
  }

  Future<void> indexAll(List<NoteModel> notes) async {
    if (_isIndexing || !ModelAvailabilityService.instance.embedding.isReady) {
      return;
    }
    _isIndexing = true;
    _knownNotes
      ..clear()
      ..addEntries(notes.map((note) => MapEntry(note.noteId, note)));
    _indexed = 0;
    _total = notes.length;
    notifyListeners();
    try {
      for (final note in notes) {
        await _indexNote(note, rebuildTopics: false);
        _indexed++;
        notifyListeners();
      }
      await _rebuildTopics(notes);
      await _enrichNewTopics(notes);
    } finally {
      _isIndexing = false;
      notifyListeners();
    }
  }

  Future<void> _indexNote(NoteModel note, {bool rebuildTopics = true}) async {
    if (!ModelAvailabilityService.instance.embedding.isReady) return;
    _knownNotes[note.noteId] = note;
    final source = _embeddingText(note);
    final sourceHash = sha256.convert(utf8.encode(source)).toString();
    final current = await _database.getNoteEmbedding(note.noteId);
    if (current?.sourceHash == sourceHash &&
        current?.modelVersion == E5EmbeddingService.modelVersion) {
      return;
    }
    final vector = await _embedder.embedDocument(source);
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.upsertNoteEmbedding(
      NoteEmbeddingsTableCompanion.insert(
        noteId: note.noteId,
        modelVersion: E5EmbeddingService.modelVersion,
        sourceHash: sourceHash,
        vector: _encodeVector(vector),
        dimensions: vector.length,
        updatedAt: now,
      ),
    );

    final all = await _database.getAllNoteEmbeddings();
    final existing = await _database.getAllRelationships();
    final existingByPair = {
      for (final item in existing)
        _pair(item.sourceNoteId, item.targetNoteId): item,
    };
    final scored = <({String id, double score})>[];
    for (final candidate in all) {
      if (candidate.noteId == note.noteId ||
          candidate.dimensions != vector.length) {
        continue;
      }
      final score = _dot(vector, _decodeVector(candidate.vector));
      final candidateNote = _knownNotes[candidate.noteId];
      final threshold =
          candidateNote != null &&
              _usesDifferentScript(note.textContent, candidateNote.textContent)
          ? 0.82
          : 0.84;
      if (score >= threshold) scored.add((id: candidate.noteId, score: score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    final relationships = <NoteRelationshipsTableCompanion>[];
    for (final match in scored.take(12)) {
      final ids = [note.noteId, match.id]..sort();
      final old = existingByPair[_pair(ids[0], ids[1])];
      relationships.add(
        NoteRelationshipsTableCompanion.insert(
          sourceNoteId: ids[0],
          targetNoteId: ids[1],
          similarity: match.score,
          status: Value(old?.status ?? 'suggested'),
          explanation: Value(
            old?.explanation ??
                'Similar meaning, subjects, or context detected on this device.',
          ),
          updatedAt: now,
        ),
      );
    }
    await _database.replaceRelationshipsForNote(note.noteId, relationships);
    if (rebuildTopics) await _rebuildTopics(null);
    notifyListeners();
  }

  Future<void> removeNote(String noteId) async {
    _knownNotes.remove(noteId);
    await _database.deleteSemanticDataForNote(noteId);
    await _rebuildTopics(null);
    notifyListeners();
  }

  Future<List<RelatedNote>> relatedNotes(
    String noteId,
    List<NoteModel> notes,
  ) async {
    final byId = {for (final note in notes) note.noteId: note};
    final relationships = await _database.getAllRelationships();
    final result = <RelatedNote>[];
    for (final link in relationships) {
      if (link.status == 'dismissed') continue;
      String? other;
      if (link.sourceNoteId == noteId) other = link.targetNoteId;
      if (link.targetNoteId == noteId) other = link.sourceNoteId;
      final note = other == null ? null : byId[other];
      if (note == null) continue;
      result.add(
        RelatedNote(
          note: note,
          similarity: link.similarity,
          status: _status(link.status),
          explanation: link.explanation ?? 'Related by meaning.',
        ),
      );
    }
    result.sort((a, b) => b.similarity.compareTo(a.similarity));
    return result;
  }

  Future<List<NoteTopic>> topics(List<NoteModel> notes) async {
    final byId = {for (final note in notes) note.noteId: note};
    final clusters = await _database.getAllTopicClusters();
    final memberships = await _database.getAllTopicMemberships();
    final result = <NoteTopic>[];
    for (final cluster in clusters) {
      if (cluster.status == 'dismissed') continue;
      final members = memberships
          .where((m) => m.clusterId == cluster.id)
          .toList();
      final topicNotes = members
          .map((m) => byId[m.noteId])
          .whereType<NoteModel>()
          .toList();
      if (topicNotes.length < 2) continue;
      final confidence = members.isEmpty
          ? 0.0
          : members.map((m) => m.confidence).reduce((a, b) => a + b) /
                members.length;
      result.add(
        NoteTopic(
          id: cluster.id,
          label: cluster.label,
          summary: cluster.summary ?? '',
          status: _status(cluster.status),
          notes: topicNotes,
          confidence: confidence,
        ),
      );
    }
    result.sort((a, b) {
      if (a.status == SemanticSuggestionStatus.confirmed &&
          b.status != SemanticSuggestionStatus.confirmed) {
        return -1;
      }
      return b.notes.length.compareTo(a.notes.length);
    });
    return result;
  }

  Future<void> setTopicStatus(
    String id,
    SemanticSuggestionStatus status,
  ) async {
    await _database.setTopicStatus(id, status.name);
    notifyListeners();
  }

  Future<void> renameTopic(NoteTopic topic, String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty || trimmed.length > 60) return;
    await _database.updateTopicContent(
      topic.id,
      label: trimmed,
      summary: topic.summary,
    );
    notifyListeners();
  }

  Future<void> setRelationshipStatus(
    String first,
    String second,
    SemanticSuggestionStatus status,
  ) async {
    final ids = [first, second]..sort();
    await _database.setRelationshipStatus(ids[0], ids[1], status.name);
    notifyListeners();
  }

  Future<void> _rebuildTopics(List<NoteModel>? suppliedNotes) async {
    final embeddings = await _database.getAllNoteEmbeddings();
    final relationships = await _database.getAllRelationships();
    final parent = {for (final item in embeddings) item.noteId: item.noteId};
    String find(String value) {
      var root = value;
      while (parent[root] != root) {
        root = parent[root]!;
      }
      var current = value;
      while (parent[current] != current) {
        final next = parent[current]!;
        parent[current] = root;
        current = next;
      }
      return root;
    }

    void union(String a, String b) {
      final left = find(a);
      final right = find(b);
      if (left != right) parent[right] = left;
    }

    for (final link in relationships) {
      if (link.status != 'dismissed' &&
          (link.status == 'confirmed' ||
              link.similarity >= _clusterThreshold(link)) &&
          parent.containsKey(link.sourceNoteId) &&
          parent.containsKey(link.targetNoteId)) {
        union(link.sourceNoteId, link.targetNoteId);
      }
    }
    final groups = <String, List<String>>{};
    for (final id in parent.keys) {
      groups.putIfAbsent(find(id), () => []).add(id);
    }
    final notes = suppliedNotes ?? _knownNotes.values.toList();
    final byId = {for (final note in notes) note.noteId: note};
    final oldClusters = await _database.getAllTopicClusters();
    final oldById = {for (final cluster in oldClusters) cluster.id: cluster};
    final now = DateTime.now().millisecondsSinceEpoch;
    final clusters = <TopicClustersTableCompanion>[];
    final memberships = <TopicMembershipsTableCompanion>[];
    for (final ids in groups.values.where((group) => group.length >= 2)) {
      ids.sort();
      final id =
          'topic_${sha1.convert(utf8.encode(ids.join('|'))).toString().substring(0, 16)}';
      final old = oldById[id];
      final groupNotes = ids
          .map((noteId) => byId[noteId])
          .whereType<NoteModel>()
          .toList();
      final label = old?.label ?? _topicLabel(groupNotes);
      clusters.add(
        TopicClustersTableCompanion.insert(
          id: id,
          label: label,
          summary: Value(
            old?.summary ??
                '${ids.length} notes connected by meaning and context.',
          ),
          status: Value(old?.status ?? 'suggested'),
          createdAt: old?.createdAt ?? now,
          updatedAt: now,
        ),
      );
      for (final noteId in ids) {
        final connected = relationships
            .where(
              (link) =>
                  link.sourceNoteId == noteId || link.targetNoteId == noteId,
            )
            .map((link) => link.similarity)
            .toList();
        memberships.add(
          TopicMembershipsTableCompanion.insert(
            clusterId: id,
            noteId: noteId,
            confidence: connected.isEmpty ? 0.78 : connected.reduce(math.max),
            updatedAt: now,
          ),
        );
      }
    }
    await _database.replaceGeneratedTopics(clusters, memberships);
  }

  String _topicLabel(List<NoteModel> notes) {
    if (notes.isEmpty) return 'Related Notes';
    const ignored = {
      'voice-memo',
      'voice-memos',
      'notes',
      'note',
      'ideas',
      'general',
      'document',
      'tasks',
      'meeting',
      'study',
      'pdf-doc',
    };
    final counts = <String, int>{};
    for (final note in notes) {
      for (final tag in note.tags) {
        final value = tag.trim().toLowerCase();
        if (value.length > 2 && !ignored.contains(value)) {
          counts[value] = (counts[value] ?? 0) + 2;
        }
      }
      for (final word in note.title.toLowerCase().split(
        RegExp(r'[^\p{L}\p{N}]+', unicode: true),
      )) {
        if (word.length > 3 && !ignored.contains(word)) {
          counts[word] = (counts[word] ?? 0) + 1;
        }
      }
    }
    if (counts.isEmpty) return 'Related Notes';
    final best = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final value = best.first.key;
    return value[0].toUpperCase() + value.substring(1);
  }

  String _embeddingText(NoteModel note) {
    final blocks = note.contentBlocks
        .map((block) => block.searchableText)
        .join('\n');
    final combined =
        '${note.title}\n${note.tags.join(', ')}\n${note.textContent}\n$blocks';
    return combined.length <= 6000 ? combined : combined.substring(0, 6000);
  }

  double _clusterThreshold(NoteRelationshipsTableData link) {
    final left = _knownNotes[link.sourceNoteId];
    final right = _knownNotes[link.targetNoteId];
    if (left != null &&
        right != null &&
        _usesDifferentScript(left.textContent, right.textContent)) {
      return 0.83;
    }
    return 0.86;
  }

  bool _usesDifferentScript(String first, String second) {
    int script(String text) {
      if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(text)) return 1;
      if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) return 2;
      if (RegExp(r'[A-Za-z]').hasMatch(text)) return 3;
      return 0;
    }

    final a = script(first);
    final b = script(second);
    return a != 0 && b != 0 && a != b;
  }

  Future<void> _enrichNewTopics(List<NoteModel> notes) async {
    if (!ModelAvailabilityService.instance.qwen.isReady) return;
    final topics = await this.topics(notes);
    final provider = QwenLlamaProvider.instance;
    if (!provider.isLoaded) await provider.load();
    for (final topic
        in topics
            .where((topic) => topic.summary.contains('connected by meaning'))
            .take(12)) {
      final evidence = topic.notes
          .take(10)
          .map((note) {
            final body = note.textContent
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();
            final excerpt = body.length > 240 ? body.substring(0, 240) : body;
            return '- ${note.title} [${note.tags.join(', ')}]: $excerpt';
          })
          .join('\n');
      try {
        final response = await provider.generate([
          const AiMessage(
            role: AiRole.system,
            content:
                'Name a group of related personal notes. Return only JSON with keys "label" and "summary". The label must be 2-5 words. The summary must be one factual sentence grounded only in the supplied notes. Do not invent information.',
          ),
          AiMessage(role: AiRole.user, content: evidence),
        ], options: const GenerationOptions(maxTokens: 120, temperature: 0.1));
        final start = response.indexOf('{');
        final end = response.lastIndexOf('}');
        if (start < 0 || end <= start) {
          continue;
        }
        final value = jsonDecode(response.substring(start, end + 1));
        if (value is! Map<String, dynamic>) {
          continue;
        }
        final label = value['label']?.toString().trim() ?? '';
        final summary = value['summary']?.toString().trim() ?? '';
        if (label.length < 2 || label.length > 60 || summary.length < 8) {
          continue;
        }
        await _database.updateTopicContent(
          topic.id,
          label: label,
          summary: summary.length > 240 ? summary.substring(0, 240) : summary,
        );
      } catch (error) {
        debugPrint('Could not enrich topic ${topic.id}: $error');
      }
    }
  }

  Uint8List _encodeVector(List<double> values) {
    final bytes = ByteData(values.length * 4);
    for (var i = 0; i < values.length; i++) {
      bytes.setFloat32(i * 4, values[i], Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  List<double> _decodeVector(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    return List<double>.generate(
      bytes.length ~/ 4,
      (index) => data.getFloat32(index * 4, Endian.little),
      growable: false,
    );
  }

  double _dot(List<double> a, List<double> b) {
    var result = 0.0;
    for (var i = 0; i < math.min(a.length, b.length); i++) {
      result += a[i] * b[i];
    }
    return result;
  }

  String _pair(String a, String b) => a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a';

  SemanticSuggestionStatus _status(String value) =>
      SemanticSuggestionStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => SemanticSuggestionStatus.suggested,
      );
}
