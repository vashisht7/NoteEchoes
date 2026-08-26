import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/domain/voice_feedback.dart';
import 'package:notechoes_app/ai/infrastructure/voice_feedback_store.dart';

void main() {
  test('feedback store appends local accepted and corrected records', () async {
    final directory = await Directory.systemTemp.createTemp(
      'notechoes-feedback-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final store = VoiceFeedbackStore(directoryProvider: () async => directory);
    final timestamp = DateTime.utc(2026, 8, 24, 12);

    await store.append(
      VoiceFeedbackRecord(
        feedbackId: 'accepted-1',
        noteId: 'note-1',
        rawTranscript: 'Um buy milk',
        modelOutput: 'Buy milk.',
        language: 'en',
        modelVersion: '5.0',
        decision: VoiceFeedbackDecision.accepted,
        createdAt: timestamp,
      ),
    );
    await store.append(
      VoiceFeedbackRecord(
        feedbackId: 'corrected-1',
        noteId: 'note-2',
        rawTranscript: 'Tuesday wait no Wednesday at four',
        modelOutput: 'Tuesday at four.',
        correctedOutput: 'Wednesday at four.',
        language: 'en',
        modelVersion: '5.0',
        decision: VoiceFeedbackDecision.corrected,
        createdAt: timestamp,
      ),
    );

    final records = await store.readAll();
    expect(records, hasLength(2));
    expect(records.first.decision, VoiceFeedbackDecision.accepted);
    expect(records.last.correctedOutput, 'Wednesday at four.');

    final file = File(
      '${directory.path}/noteechoes_rl_feedback/feedback.jsonl',
    );
    final contents = await file.readAsString();
    expect(contents, contains('"upload_consent":false'));
  });
}
