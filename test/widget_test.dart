import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/main.dart';
import 'package:notechoes_app/screens/home_screen.dart';
import 'package:notechoes_app/screens/note_detail_screen.dart';
import 'package:notechoes_app/services/ai_categorization_engine.dart';
import 'package:notechoes_app/services/note_service.dart';
import 'package:notechoes_app/models/note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notechoes_app/services/note_storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    NoteService().clearNotesForTesting();
    NoteService().setBackgroundIndexingForTesting(false);
    await NoteStorageService().useInMemoryDatabaseForTesting();
  });

  group('AiCategorizationEngine Tests', () {
    final engine = AiCategorizationEngine();

    test('Categorizes Math and Formula Notes correctly', () {
      const mathNote =
          r"Calculate the Gaussian integral $$\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}$$ for probability.";
      final result = engine.analyzeNote(mathNote);

      expect(result.categories.contains('math'), isTrue);
      expect(result.title.isNotEmpty, isTrue);
    });

    test('Categorizes Grocery List and extracts checklist items', () {
      const groceryNote =
          "Need to buy oat milk, fresh eggs, sourdough bread, and coffee beans from the supermarket\n- [ ] Oat milk\n- [ ] Eggs\n- [ ] Coffee";
      final result = engine.analyzeNote(groceryNote);

      expect(result.categories.contains('grocery'), isTrue);
      expect(result.extractedChecklist.length, equals(3));
    });

    test('Categorizes Tasks and Deadlines correctly', () {
      const taskNote =
          "Remember to finish the Stage UI system tokens and glassmorphism sprint deliverable by Friday.";
      final result = engine.analyzeNote(taskNote);

      expect(result.categories.contains('tasks'), isTrue);
    });

    test('Categorizes Meeting Discussions', () {
      const meetingNote =
          "Client sync meeting agenda: discuss mobile deployment, TestFlight distribution, and offline latency benchmarks.";
      final result = engine.analyzeNote(meetingNote);

      expect(result.categories.contains('meeting'), isTrue);
    });
  });

  group('NoteService Integration Tests', () {
    test('natural enumerated voice speech saves as checklist', () async {
      final note = await NoteService().createFromVoiceTranscription(
        'First task, I want to check whether the model works. Second, I want to check whether the app works.',
      );

      expect(note.checklist.map((item) => item.text), [
        'check whether the model works',
        'check whether the app works',
      ]);
      await NoteService().waitForPendingIndexingForTesting();
    });

    test(
      'createFromVoiceTranscription saves note with AI categories',
      () async {
        final service = NoteService();
        final initialCount = service.allNotes.length;

        final note = await service.createFromVoiceTranscription(
          "Brainstorming new startup ideas for spatial audio notes.",
        );

        expect(service.allNotes.length, equals(initialCount + 1));
        expect(note.tags.contains('ideas'), isTrue);
        expect(note.title.isNotEmpty, isTrue);
        await service.waitForPendingIndexingForTesting();
      },
    );

    test('multilingual text and table blocks survive persistence encoding', () {
      final original = NoteModel(
        noteId: 'multilingual-table',
        title: 'ప్రాజెక్ట్ योजना',
        contentType: NoteContentType.textOnly,
        summarySnippet: 'తెలుగు और हिन्दी',
        textContent: 'తెలుగు और हिन्दी\nName | स्थिति',
        createdAt: DateTime.utc(2026, 1, 2),
        contentBlocks: const [
          NoteBlockData.text('తెలుగు और हिन्दी'),
          NoteBlockData.table([
            ['Name', 'स्थिति'],
            ['పని', 'पूर्ण'],
          ]),
        ],
      );

      final restored = NoteModel.fromJson(original.toJson());
      expect(restored.title, original.title);
      expect(restored.contentBlocks.length, 2);
      expect(restored.contentBlocks.last.tableCells[1][0], 'పని');
      expect(restored.contentBlocks.last.searchableText, contains('स्थिति'));
    });

    testWidgets('voice checklist editor hides duplicate transcript', (
      tester,
    ) async {
      final note = NoteModel(
        noteId: 'pure-checklist',
        title: 'Checklist',
        contentType: NoteContentType.textOnly,
        summarySnippet: 'First task model. Second task app.',
        textContent: 'First task model. Second task app.',
        createdAt: DateTime(2026),
        tags: const ['voice-memo', 'tasks'],
        checklist: [
          CheckListItem(id: 'one', text: 'Check the model'),
          CheckListItem(id: 'two', text: 'Check the app'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: NoteDetailScreen(existingNote: note)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Check the model'), findsOneWidget);
      expect(find.text('Check the app'), findsOneWidget);
      expect(find.text('First task model. Second task app.'), findsNothing);
      expect(find.byTooltip('Mark complete'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Mark complete').first);
      await tester.pump();
      expect(find.byTooltip('Mark incomplete'), findsOneWidget);
    });
  });

  group('UI & Widget Smoke Tests', () {
    testWidgets('NoteEchoes loads and displays header and quick actions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const NoteEchoesApp());
      await tester.pumpAndSettle();

      expect(find.text('notechoes'), findsWidgets);
      expect(find.text('Action Button Siri Note'), findsNothing);
      expect(find.text('Voice Mode'), findsOneWidget);
      expect(find.text('Write Note'), findsOneWidget);
    });

    testWidgets('Search button returns to an unfiltered home page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const NoteEchoesApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Search Notes'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Keyword search'), findsOneWidget);

      NoteService().setSearchQuery('temporary filter');
      await tester.tap(find.byTooltip('Search Notes'));
      await tester.pumpAndSettle();
      expect(NoteService().searchQuery, isEmpty);
      expect(find.textContaining('Keyword search'), findsNothing);
    });

    testWidgets('Topics entry fits a compact iPhone home screen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const NoteEchoesApp());
      await tester.pumpAndSettle();

      expect(find.text('Topics'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Done saves a note and returns to a stable compact home page', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const NoteEchoesApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Write Note'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('note_title_field')),
        'Saved from Done',
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('note_done_button')));
      for (var attempt = 0; attempt < 30; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(HomeScreen).evaluate().isNotEmpty &&
            find.byKey(const ValueKey('note_done_button')).evaluate().isEmpty) {
          break;
        }
      }

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('notechoes'), findsOneWidget);
      expect(find.text('Saved from Done'), findsOneWidget);
      expect(find.byKey(const ValueKey('note_done_button')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
