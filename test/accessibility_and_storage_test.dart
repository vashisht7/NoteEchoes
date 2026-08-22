import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/models/note_model.dart';
import 'package:notechoes_app/models/note_node.dart';
import 'package:notechoes_app/services/note_storage_service.dart';
import 'package:notechoes_app/widgets/inline_note_table.dart';
import 'package:notechoes_app/widgets/keep_text_note_card.dart';
import 'package:notechoes_app/widgets/voice_visualizer_painter.dart';
import 'package:notechoes_app/screens/voice_assistant_screen.dart';
import 'package:notechoes_app/services/voice_assistant_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:notechoes_app/ai/infrastructure/ai_database.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'legacy preference notes migrate into SQLite without data loss',
    () async {
      final storage = NoteStorageService();
      await storage.useInMemoryDatabaseForTesting();
      final legacy = NoteModel(
        noteId: 'legacy-note',
        title: 'Existing phone note',
        contentType: NoteContentType.textOnly,
        summarySnippet: 'Preserve me',
        textContent: 'Preserve me',
        createdAt: DateTime.utc(2025, 12, 1),
      );
      SharedPreferences.setMockInitialValues({
        'notechoes_saved_notes_v1': jsonEncode([legacy.toJson()]),
      });
      await storage.migrateLegacyNotesForTesting();
      final restored = await storage.loadNotes();
      expect(restored.single.noteId, 'legacy-note');
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.containsKey('notechoes_saved_notes_v1'), isFalse);
    },
  );

  test('SQLite note store handles large collections and updates', () async {
    final storage = NoteStorageService();
    await storage.useInMemoryDatabaseForTesting();
    final notes = List.generate(
      750,
      (index) => NoteModel(
        noteId: 'note-$index',
        title: 'Note $index',
        contentType: NoteContentType.textOnly,
        summarySnippet: 'Summary $index',
        textContent: 'Body $index',
        createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: index)),
      ),
    );
    await storage.saveNotes(notes);
    await storage.upsertNote(notes[400].copyWith(title: 'Updated title'));

    final restored = await storage.loadNotes();
    expect(restored, hasLength(750));
    expect(
      restored.singleWhere((note) => note.noteId == 'note-400').title,
      'Updated title',
    );
  });

  test('semantic relationships and topic decisions persist locally', () async {
    final database = AiDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.utc(2026, 8, 17).millisecondsSinceEpoch;
    await database.upsertNoteEmbedding(
      NoteEmbeddingsTableCompanion.insert(
        noteId: 'fitness-plan',
        modelVersion: 'e5-test',
        sourceHash: 'hash-a',
        vector: Uint8List.fromList([0, 0, 128, 63]),
        dimensions: 1,
        updatedAt: now,
      ),
    );
    await database.replaceRelationshipsForNote('fitness-plan', [
      NoteRelationshipsTableCompanion.insert(
        sourceNoteId: 'fitness-plan',
        targetNoteId: 'workout-dashboard',
        similarity: 0.88,
        explanation: const Value('Both discuss workout tracking.'),
        updatedAt: now,
      ),
    ]);
    await database.replaceGeneratedTopics(
      [
        TopicClustersTableCompanion.insert(
          id: 'topic-fitness',
          label: 'Fitness App',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      [
        TopicMembershipsTableCompanion.insert(
          clusterId: 'topic-fitness',
          noteId: 'fitness-plan',
          confidence: 0.88,
          updatedAt: now,
        ),
        TopicMembershipsTableCompanion.insert(
          clusterId: 'topic-fitness',
          noteId: 'workout-dashboard',
          confidence: 0.88,
          updatedAt: now,
        ),
      ],
    );
    await database.setTopicStatus('topic-fitness', 'confirmed');
    await database.setRelationshipStatus(
      'fitness-plan',
      'workout-dashboard',
      'confirmed',
    );

    expect((await database.getAllNoteEmbeddings()).single.dimensions, 1);
    expect((await database.getAllRelationships()).single.status, 'confirmed');
    expect((await database.getAllTopicClusters()).single.status, 'confirmed');
    expect(await database.getAllTopicMemberships(), hasLength(2));
  });

  testWidgets('table Return creates a row and exposes cell semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: InlineNoteTable())),
    );
    await tester.tap(find.byKey(const ValueKey('table_cell_1_1')));
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(find.byKey(const ValueKey('table_cell_2_0')), findsOneWidget);
    expect(
      find.bySemanticsLabel('Table cell, row 3, column 1'),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel('Add table column'));
    await tester.pump();
    expect(find.byKey(const ValueKey('table_cell_0_2')), findsOneWidget);
    semantics.dispose();
  });

  test('checklist blocks preserve their intended position', () {
    const blocks = [
      NoteBlockData.text('Before'),
      NoteBlockData.checklist(
        checklistId: 'task-1',
        checklistText: 'Call the client',
        checklistCompleted: false,
      ),
      NoteBlockData.text('After'),
    ];
    final restored = blocks
        .map((block) => NoteBlockData.fromJson(block.toJson()))
        .toList();
    expect(restored.map((block) => block.type), [
      NoteBlockType.text,
      NoteBlockType.checklist,
      NoteBlockType.text,
    ]);
    expect(restored[1].checklistText, 'Call the client');
  });

  testWidgets('note card supports VoiceOver and large Dynamic Type', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final note = NoteModel(
      noteId: 'accessible-note',
      title: 'Accessible note',
      contentType: NoteContentType.textOnly,
      summarySnippet: 'Readable summary',
      textContent: 'Readable summary',
      createdAt: DateTime.utc(2026, 1, 1),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: Scaffold(
            body: SizedBox(width: 320, child: KeepTextNoteCard(note: note)),
          ),
        ),
      ),
    );
    expect(
      find.bySemanticsLabel(RegExp('Accessible note.*Readable summary')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('conversation controls do not overflow on a compact iPhone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final voiceService = VoiceAssistantService();
    await voiceService.transitionToSpeakingState();

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.4),
            disableAnimations: true,
          ),
          child: const Scaffold(
            body: VoiceAssistantScreen(currentState: VoiceState.speaking),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byKey(const ValueKey('integrated_insight_card')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await voiceService.stopVoiceSession();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
