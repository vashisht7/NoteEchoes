import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'ai_database.dart';

class AiJobQueue {
  static AiJobQueue? _instance;
  final AiDatabase database;
  bool _isProcessing = false;

  AiJobQueue._internal(this.database);

  factory AiJobQueue(AiDatabase database) {
    _instance ??= AiJobQueue._internal(database);
    return _instance!;
  }

  Future<String> enqueue({
    required String jobType,
    required String sourceId,
    required String sourceHash,
    required String modelVersion,
  }) async {
    final existingJob = await database.findExistingJob(sourceId, sourceHash, modelVersion);
    if (existingJob != null) {
      return existingJob.id;
    }

    final jobId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await database.upsertJob(AiJobsTableCompanion(
      id: Value(jobId),
      jobType: Value(jobType),
      sourceId: Value(sourceId),
      sourceHash: Value(sourceHash),
      modelVersion: Value(modelVersion),
      status: const Value('queued'),
      createdAt: Value(now),
    ));

    return jobId;
  }

  Future<void> processNext(Future<void> Function(AiJobsTableData job) processor) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final queuedJobs = await database.getJobsByStatus('queued');
      if (queuedJobs.isEmpty) return;

      final job = queuedJobs.first;
      
      await database.updateJobStatus(
        job.id, 
        'running',
      );

      try {
        await processor(job);
        
        await database.updateJobStatus(
          job.id, 
          'completed',
          completedAt: DateTime.now().millisecondsSinceEpoch,
        );
      } catch (e) {
        final newAttemptCount = job.attemptCount + 1;
        
        await (database.update(database.aiJobsTable)..where((t) => t.id.equals(job.id))).write(
          AiJobsTableCompanion(
            status: const Value('failed'),
            attemptCount: Value(newAttemptCount),
            errorCode: Value(e.toString()),
          )
        );
      }
    } finally {
      _isProcessing = false;
    }
  }

  Stream<List<AiJobsTableData>> watchQueuedJobs() {
    return (database.select(database.aiJobsTable)
          ..where((t) => t.status.equals('queued'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> cancelJob(String jobId) async {
    await database.updateJobStatus(jobId, 'cancelled');
  }

  Future<void> retryFailed() async {
    final failedJobs = await (database.select(database.aiJobsTable)
          ..where((t) => t.status.equals('failed')))
        .get();

    for (final job in failedJobs) {
      if (job.attemptCount < 3) {
        await database.updateJobStatus(job.id, 'queued');
      }
    }
  }
}
