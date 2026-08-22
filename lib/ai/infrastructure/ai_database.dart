// ai_database.dart
// Drift (SQLite) database for all AI-related persistence.
// This sits alongside the existing SharedPreferences store —
// it does NOT replace or touch the 'notechoes_saved_notes_v1' key.

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'ai_database.g.dart';

// ── Tables ────────────────────────────────────────────────────────────────────

class AiNoteAnalysisTable extends Table {
  @override
  String get tableName => 'ai_note_analysis';

  TextColumn get noteId => text()();
  TextColumn get modelVersion => text()();
  TextColumn get sourceHash => text()();
  TextColumn get detectedLanguage => text()();
  TextColumn get generatedTitle => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get englishRetrievalSummary => text().nullable()();
  TextColumn get topicsJson => text().nullable()();
  TextColumn get peopleJson => text().nullable()();
  TextColumn get placesJson => text().nullable()();
  TextColumn get suggestedTagsJson => text().nullable()();
  TextColumn get actionItemsJson => text().nullable()();
  TextColumn get eventsJson => text().nullable()();
  TextColumn get remindersJson => text().nullable()();
  TextColumn get travelDetailsJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {noteId};
}

class TranscriptSegmentsTable extends Table {
  @override
  String get tableName => 'transcript_segments';

  TextColumn get id => text()();
  TextColumn get noteId => text()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  TextColumn get language => text()();
  TextColumn get segmentText => text()();
  RealColumn get confidence => real()();
  TextColumn get speakerLabel => text().nullable()();
  IntColumn get sequenceNumber => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class DocumentsTable extends Table {
  @override
  String get tableName => 'documents';

  TextColumn get id => text()();
  TextColumn get notebookId => text().nullable()();
  TextColumn get localPath => text()();
  TextColumn get sha256 => text()();
  TextColumn get title => text()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get processingState =>
      text().withDefault(const Constant('pending'))();
  TextColumn get processingError => text().nullable()();
  IntColumn get importedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class DocumentChunksTable extends Table {
  @override
  String get tableName => 'document_chunks';

  TextColumn get id => text()();
  TextColumn get documentId => text()();
  IntColumn get pageStart => integer()();
  IntColumn get pageEnd => integer()();
  TextColumn get chapter => text().nullable()();
  TextColumn get originalText => text()();
  TextColumn get englishRetrievalText => text().nullable()();
  TextColumn get keywords => text().nullable()();
  IntColumn get tokenEstimate => integer().nullable()();
  IntColumn get sourceOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SuggestedActionsTable extends Table {
  @override
  String get tableName => 'suggested_actions';

  TextColumn get id => text()();
  TextColumn get noteId => text()();
  TextColumn get actionType => text()();
  TextColumn get title => text()();
  TextColumn get detailsJson => text()();
  TextColumn get evidenceText => text()();
  IntColumn get sourceStartMs => integer().nullable()();
  IntColumn get sourceEndMs => integer().nullable()();
  IntColumn get sourcePage => integer().nullable()();
  RealColumn get confidence => real()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class PersonalMemoriesTable extends Table {
  @override
  String get tableName => 'personal_memories';

  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get value => text()();
  TextColumn get sourceNoteId => text().nullable()();
  IntColumn get userConfirmed => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AiJobsTable extends Table {
  @override
  String get tableName => 'ai_jobs';

  TextColumn get id => text()();
  TextColumn get jobType => text()();
  TextColumn get sourceId => text()();
  TextColumn get sourceHash => text()();
  TextColumn get modelVersion => text()();
  TextColumn get status => text().withDefault(const Constant('queued'))();
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get errorCode => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get completedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ModelInstallationsTable extends Table {
  @override
  String get tableName => 'model_installations';

  TextColumn get modelId => text()();
  TextColumn get version => text()();
  TextColumn get localPath => text()();
  TextColumn get expectedSha256 => text()();
  TextColumn get actualSha256 => text().nullable()();
  IntColumn get sizeBytes => integer()();
  TextColumn get installationState =>
      text().withDefault(const Constant('not_installed'))();
  IntColumn get installedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {modelId};
}

class NoteEmbeddingsTable extends Table {
  @override
  String get tableName => 'note_embeddings';

  TextColumn get noteId => text()();
  TextColumn get modelVersion => text()();
  TextColumn get sourceHash => text()();
  BlobColumn get vector => blob()();
  IntColumn get dimensions => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {noteId};
}

class NoteRelationshipsTable extends Table {
  @override
  String get tableName => 'note_relationships';

  TextColumn get sourceNoteId => text()();
  TextColumn get targetNoteId => text()();
  RealColumn get similarity => real()();
  TextColumn get status => text().withDefault(const Constant('suggested'))();
  TextColumn get explanation => text().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {sourceNoteId, targetNoteId};
}

class TopicClustersTable extends Table {
  @override
  String get tableName => 'topic_clusters';

  TextColumn get id => text()();
  TextColumn get label => text()();
  TextColumn get summary => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('suggested'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class TopicMembershipsTable extends Table {
  @override
  String get tableName => 'topic_memberships';

  TextColumn get clusterId => text()();
  TextColumn get noteId => text()();
  RealColumn get confidence => real()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {clusterId, noteId};
}

class NoteInterpretationsTable extends Table {
  @override
  String get tableName => 'note_interpretations';

  TextColumn get noteId => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  TextColumn get rawTranscript => text()();
  TextColumn get normalizedText => text()();
  TextColumn get primaryLanguage => text()();
  TextColumn get mixedLanguagesJson => text().withDefault(const Constant('[]'))();
  TextColumn get intentsJson => text().withDefault(const Constant('[]'))();
  TextColumn get entitiesJson => text().withDefault(const Constant('[]'))();
  TextColumn get projectCandidatesJson => text().withDefault(const Constant('[]'))();
  TextColumn get agentPromptJson => text().nullable()();
  TextColumn get provenanceJson => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {noteId};
}

class KnownProjectsTable extends Table {
  @override
  String get tableName => 'known_projects';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get aliasesJson => text().withDefault(const Constant('[]'))();
  TextColumn get description => text().nullable()();
  IntColumn get lastReferencedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class KnownApplicationsTable extends Table {
  @override
  String get tableName => 'known_applications';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bundleId => text().nullable()();
  TextColumn get aliasesJson => text().withDefault(const Constant('[]'))();
  TextColumn get description => text().nullable()();
  IntColumn get lastReferencedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class DraftCommunicationsTable extends Table {
  @override
  String get tableName => 'draft_communications';

  TextColumn get id => text()();
  TextColumn get noteId => text()();
  TextColumn get type => text()(); // 'email' or 'message'
  TextColumn get recipient => text().nullable()();
  TextColumn get subject => text().nullable()();
  TextColumn get body => text()();
  TextColumn get resolvedChannel => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))(); // 'draft', 'confirmed', 'sent', 'dismissed'
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class AgentPromptDraftsTable extends Table {
  @override
  String get tableName => 'agent_prompt_drafts';

  TextColumn get id => text()();
  TextColumn get noteId => text()();
  TextColumn get goal => text()();
  TextColumn get context => text()();
  TextColumn get requirementsJson => text().withDefault(const Constant('[]'))();
  TextColumn get constraintsJson => text().withDefault(const Constant('[]'))();
  TextColumn get acceptanceCriteriaJson => text().withDefault(const Constant('[]'))();
  TextColumn get relevantFilesJson => text().withDefault(const Constant('[]'))();
  TextColumn get nonGoalsJson => text().withDefault(const Constant('[]'))();
  TextColumn get openQuestionsJson => text().withDefault(const Constant('[]'))();
  RealColumn get confidence => real()();
  TextColumn get status => text().withDefault(const Constant('draft'))(); // 'draft', 'copied', 'dismissed'
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class InterpretationFeedbackTable extends Table {
  @override
  String get tableName => 'interpretation_feedback';

  TextColumn get id => text()();
  TextColumn get noteId => text()();
  TextColumn get correctedField => text()();
  TextColumn get originalValue => text().nullable()();
  TextColumn get correctedValue => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database class ────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    AiNoteAnalysisTable,
    TranscriptSegmentsTable,
    DocumentsTable,
    DocumentChunksTable,
    SuggestedActionsTable,
    PersonalMemoriesTable,
    AiJobsTable,
    ModelInstallationsTable,
    NoteEmbeddingsTable,
    NoteRelationshipsTable,
    TopicClustersTable,
    TopicMembershipsTable,
    NoteInterpretationsTable,
    KnownProjectsTable,
    KnownApplicationsTable,
    DraftCommunicationsTable,
    AgentPromptDraftsTable,
    InterpretationFeedbackTable,
  ],
)
class AiDatabase extends _$AiDatabase {
  AiDatabase() : super(_openConnection());
  AiDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createFtsTables();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(noteEmbeddingsTable);
        await m.createTable(noteRelationshipsTable);
        await m.createTable(topicClustersTable);
        await m.createTable(topicMembershipsTable);
      }
      if (from < 3) {
        await m.createTable(noteInterpretationsTable);
        await m.createTable(knownProjectsTable);
        await m.createTable(knownApplicationsTable);
        await m.createTable(draftCommunicationsTable);
        await m.createTable(agentPromptDraftsTable);
        await m.createTable(interpretationFeedbackTable);
      }
    },
  );

  Future<void> _createFtsTables() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS content_fts USING fts5(
        source_id UNINDEXED,
        source_type UNINDEXED,
        title,
        original_text,
        english_retrieval_text,
        keywords,
        people,
        places,
        dates,
        tokenize = 'unicode61'
      )
      ''');
  }

  // ── Note analysis ─────────────────────────────────────────────

  Future<AiNoteAnalysisTableData?> getAnalysisForNote(String noteId) => (select(
    aiNoteAnalysisTable,
  )..where((t) => t.noteId.equals(noteId))).getSingleOrNull();

  Future<void> upsertAnalysis(AiNoteAnalysisTableCompanion data) =>
      into(aiNoteAnalysisTable).insertOnConflictUpdate(data);

  // ── Transcript segments ───────────────────────────────────────

  Future<List<TranscriptSegmentsTableData>> getSegmentsForNote(String noteId) =>
      (select(transcriptSegmentsTable)
            ..where((t) => t.noteId.equals(noteId))
            ..orderBy([(t) => OrderingTerm.asc(t.sequenceNumber)]))
          .get();

  Future<void> insertSegment(TranscriptSegmentsTableCompanion segment) => into(
    transcriptSegmentsTable,
  ).insert(segment, mode: InsertMode.insertOrReplace);

  Future<void> deleteSegmentsForNote(String noteId) => (delete(
    transcriptSegmentsTable,
  )..where((t) => t.noteId.equals(noteId))).go();

  // ── Documents ─────────────────────────────────────────────────

  Future<List<DocumentsTableData>> getAllDocuments() =>
      select(documentsTable).get();

  Future<DocumentsTableData?> getDocument(String id) =>
      (select(documentsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertDocument(DocumentsTableCompanion data) =>
      into(documentsTable).insertOnConflictUpdate(data);

  Future<void> updateDocumentState(
    String id,
    String state, [
    String? error,
  ]) async {
    await (update(documentsTable)..where((t) => t.id.equals(id))).write(
      DocumentsTableCompanion(
        processingState: Value(state),
        processingError: Value(error),
      ),
    );
  }

  Future<void> updateDocumentPageCount(String id, int pageCount) =>
      (update(documentsTable)..where((t) => t.id.equals(id))).write(
        DocumentsTableCompanion(pageCount: Value(pageCount)),
      );

  // ── Document chunks ───────────────────────────────────────────

  Future<List<DocumentChunksTableData>> getChunksForDocument(
    String documentId,
  ) =>
      (select(documentChunksTable)
            ..where((t) => t.documentId.equals(documentId))
            ..orderBy([(t) => OrderingTerm.asc(t.sourceOrder)]))
          .get();

  Future<void> insertChunk(DocumentChunksTableCompanion chunk) =>
      into(documentChunksTable).insert(chunk, mode: InsertMode.insertOrReplace);

  Future<void> deleteChunksForDocument(String documentId) => (delete(
    documentChunksTable,
  )..where((t) => t.documentId.equals(documentId))).go();

  // ── Suggested actions ─────────────────────────────────────────

  Future<List<SuggestedActionsTableData>> getPendingActionsForNote(
    String noteId,
  ) => (select(
    suggestedActionsTable,
  )..where((t) => t.noteId.equals(noteId) & t.status.equals('pending'))).get();

  Future<void> upsertSuggestedAction(SuggestedActionsTableCompanion data) =>
      into(suggestedActionsTable).insertOnConflictUpdate(data);

  Future<void> updateActionStatus(String id, String status) =>
      (update(suggestedActionsTable)..where((t) => t.id.equals(id))).write(
        SuggestedActionsTableCompanion(status: Value(status)),
      );

  // ── AI jobs ───────────────────────────────────────────────────

  Future<List<AiJobsTableData>> getJobsByStatus(String status) =>
      (select(aiJobsTable)
            ..where((t) => t.status.equals(status))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<AiJobsTableData?> findExistingJob(
    String sourceId,
    String sourceHash,
    String modelVersion,
  ) =>
      (select(aiJobsTable)..where(
            (t) =>
                t.sourceId.equals(sourceId) &
                t.sourceHash.equals(sourceHash) &
                t.modelVersion.equals(modelVersion),
          ))
          .getSingleOrNull();

  Future<void> upsertJob(AiJobsTableCompanion data) =>
      into(aiJobsTable).insertOnConflictUpdate(data);

  Future<void> updateJobStatus(
    String id,
    String status, {
    double? progress,
    String? errorCode,
    int? completedAt,
  }) async {
    var companion = AiJobsTableCompanion(status: Value(status));
    if (progress != null) {
      companion = companion.copyWith(progress: Value(progress));
    }
    if (errorCode != null) {
      companion = companion.copyWith(errorCode: Value(errorCode));
    }
    if (completedAt != null) {
      companion = companion.copyWith(completedAt: Value(completedAt));
    }
    await (update(aiJobsTable)..where((t) => t.id.equals(id))).write(companion);
  }

  // ── Model installations ───────────────────────────────────────

  Future<ModelInstallationsTableData?> getModelInstallation(String modelId) =>
      (select(
        modelInstallationsTable,
      )..where((t) => t.modelId.equals(modelId))).getSingleOrNull();

  Future<void> upsertModelInstallation(ModelInstallationsTableCompanion data) =>
      into(modelInstallationsTable).insertOnConflictUpdate(data);

  // ── FTS5 helpers ──────────────────────────────────────────────

  Future<void> ftsUpsert({
    required String sourceId,
    required String sourceType,
    required String title,
    required String originalText,
    String? englishRetrievalText,
    String? keywords,
    String? people,
    String? places,
    String? dates,
  }) async {
    await customStatement('DELETE FROM content_fts WHERE source_id = ?', [
      sourceId,
    ]);
    await customStatement(
      'INSERT INTO content_fts (source_id, source_type, title, '
      'original_text, english_retrieval_text, keywords, people, '
      'places, dates) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        sourceId,
        sourceType,
        title,
        originalText,
        englishRetrievalText ?? '',
        keywords ?? '',
        people ?? '',
        places ?? '',
        dates ?? '',
      ],
    );
  }

  Future<List<Map<String, Object?>>> ftsSearch(String query, int limit) async {
    final rows = await customSelect(
      "SELECT source_id, source_type, title, original_text, "
      "english_retrieval_text, keywords, people, places, dates, "
      "bm25(content_fts) AS score "
      "FROM content_fts WHERE content_fts MATCH ? "
      "ORDER BY score LIMIT ?",
      variables: [Variable.withString(query), Variable.withInt(limit)],
    ).get();
    return rows.map((r) => r.data).toList();
  }

  Future<void> ftsDelete(String sourceId) async {
    await customStatement('DELETE FROM content_fts WHERE source_id = ?', [
      sourceId,
    ]);
  }

  // ── Missing helpers used by application layer ─────────────────

  /// Update a model installation status (called by ModelDownloadService).
  Future<void> updateModelInstallationStatus(
    String modelId,
    String status,
  ) async {
    await (update(
      modelInstallationsTable,
    )..where((t) => t.modelId.equals(modelId))).write(
      ModelInstallationsTableCompanion(installationState: Value(status)),
    );
  }

  Future<void> deleteSemanticDataForNote(String noteId) async {
    await transaction(() async {
      await (delete(
        noteEmbeddingsTable,
      )..where((t) => t.noteId.equals(noteId))).go();
      await (delete(noteRelationshipsTable)..where(
            (t) =>
                t.sourceNoteId.equals(noteId) | t.targetNoteId.equals(noteId),
          ))
          .go();
      await (delete(
        topicMembershipsTable,
      )..where((t) => t.noteId.equals(noteId))).go();
    });
  }

  Future<NoteEmbeddingsTableData?> getNoteEmbedding(String noteId) => (select(
    noteEmbeddingsTable,
  )..where((t) => t.noteId.equals(noteId))).getSingleOrNull();

  Future<List<NoteEmbeddingsTableData>> getAllNoteEmbeddings() =>
      select(noteEmbeddingsTable).get();

  Future<void> upsertNoteEmbedding(NoteEmbeddingsTableCompanion value) =>
      into(noteEmbeddingsTable).insertOnConflictUpdate(value);

  Future<void> replaceRelationshipsForNote(
    String noteId,
    List<NoteRelationshipsTableCompanion> relationships,
  ) async {
    await transaction(() async {
      await (delete(noteRelationshipsTable)..where(
            (t) =>
                (t.sourceNoteId.equals(noteId) |
                    t.targetNoteId.equals(noteId)) &
                t.status.equals('suggested'),
          ))
          .go();
      for (final relationship in relationships) {
        await into(noteRelationshipsTable).insertOnConflictUpdate(relationship);
      }
    });
  }

  Future<List<NoteRelationshipsTableData>> getAllRelationships() =>
      select(noteRelationshipsTable).get();

  Future<void> setRelationshipStatus(
    String sourceId,
    String targetId,
    String status,
  ) =>
      (update(noteRelationshipsTable)..where(
            (t) =>
                t.sourceNoteId.equals(sourceId) &
                t.targetNoteId.equals(targetId),
          ))
          .write(NoteRelationshipsTableCompanion(status: Value(status)));

  Future<List<TopicClustersTableData>> getAllTopicClusters() =>
      select(topicClustersTable).get();

  Future<List<TopicMembershipsTableData>> getAllTopicMemberships() =>
      select(topicMembershipsTable).get();

  Future<void> replaceGeneratedTopics(
    List<TopicClustersTableCompanion> clusters,
    List<TopicMembershipsTableCompanion> memberships,
  ) async {
    await transaction(() async {
      final retained = await (select(
        topicClustersTable,
      )..where((t) => t.status.isNotIn(const ['suggested']))).get();
      await delete(topicMembershipsTable).go();
      await delete(topicClustersTable).go();
      for (final cluster in retained) {
        await into(topicClustersTable).insertOnConflictUpdate(
          TopicClustersTableCompanion.insert(
            id: cluster.id,
            label: cluster.label,
            summary: Value(cluster.summary),
            status: Value(cluster.status),
            createdAt: cluster.createdAt,
            updatedAt: cluster.updatedAt,
          ),
        );
      }
      for (final cluster in clusters) {
        await into(topicClustersTable).insertOnConflictUpdate(cluster);
      }
      for (final membership in memberships) {
        await into(topicMembershipsTable).insertOnConflictUpdate(membership);
      }
    });
  }

  Future<void> setTopicStatus(String id, String status) =>
      (update(topicClustersTable)..where((t) => t.id.equals(id))).write(
        TopicClustersTableCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> updateTopicContent(
    String id, {
    required String label,
    required String summary,
  }) => (update(topicClustersTable)..where((t) => t.id.equals(id))).write(
    TopicClustersTableCompanion(
      label: Value(label),
      summary: Value(summary),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );

  /// Get expected SHA-256 for a model (called by ModelIntegrityService).
  Future<String?> getExpectedSha256(String modelId) async {
    final row = await getModelInstallation(modelId);
    return row?.expectedSha256;
  }

  // ── Note interpretations ──────────────────────────────────────

  Future<NoteInterpretationsTableData?> getInterpretationForNote(String noteId) =>
      (select(noteInterpretationsTable)..where((t) => t.noteId.equals(noteId)))
          .getSingleOrNull();

  Future<void> upsertInterpretation(NoteInterpretationsTableCompanion data) =>
      into(noteInterpretationsTable).insertOnConflictUpdate(data);

  // ── Known projects & applications ─────────────────────────────

  Future<List<KnownProjectsTableData>> getAllKnownProjects() =>
      select(knownProjectsTable).get();

  Future<void> upsertKnownProject(KnownProjectsTableCompanion project) =>
      into(knownProjectsTable).insertOnConflictUpdate(project);

  Future<List<KnownApplicationsTableData>> getAllKnownApplications() =>
      select(knownApplicationsTable).get();

  Future<void> upsertKnownApplication(KnownApplicationsTableCompanion app) =>
      into(knownApplicationsTable).insertOnConflictUpdate(app);

  // ── Draft communications & agent prompts ──────────────────────

  Future<List<DraftCommunicationsTableData>> getDraftCommunicationsForNote(
    String noteId,
  ) =>
      (select(draftCommunicationsTable)..where((t) => t.noteId.equals(noteId)))
          .get();

  Future<void> upsertDraftCommunication(DraftCommunicationsTableCompanion draft) =>
      into(draftCommunicationsTable).insertOnConflictUpdate(draft);

  Future<AgentPromptDraftsTableData?> getAgentPromptDraftForNote(String noteId) =>
      (select(agentPromptDraftsTable)..where((t) => t.noteId.equals(noteId)))
          .getSingleOrNull();

  Future<void> upsertAgentPromptDraft(AgentPromptDraftsTableCompanion prompt) =>
      into(agentPromptDraftsTable).insertOnConflictUpdate(prompt);

  Future<void> insertInterpretationFeedback(
    InterpretationFeedbackTableCompanion feedback,
  ) =>
      into(interpretationFeedbackTable).insert(feedback);
}

// ── Connection factory ────────────────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'notechoes_ai.sqlite'));
    return NativeDatabase(file, logStatements: false);
  });
}
