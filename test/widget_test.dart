import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/main.dart';
import 'package:notechoes_app/services/ai_categorization_engine.dart';
import 'package:notechoes_app/services/note_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NoteService().clearNotesForTesting();
  });

  group('AiCategorizationEngine Tests', () {
    final engine = AiCategorizationEngine();

    test('Categorizes Math and Formula Notes correctly', () {
      const mathNote = r"Calculate the Gaussian integral $$\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}$$ for probability.";
      final result = engine.analyzeNote(mathNote);

      expect(result.categories.contains('math'), isTrue);
      expect(result.title.isNotEmpty, isTrue);
    });

    test('Categorizes Grocery List and extracts checklist items', () {
      const groceryNote = "Need to buy oat milk, fresh eggs, sourdough bread, and coffee beans from the supermarket\n- [ ] Oat milk\n- [ ] Eggs\n- [ ] Coffee";
      final result = engine.analyzeNote(groceryNote);

      expect(result.categories.contains('grocery'), isTrue);
      expect(result.extractedChecklist.length, equals(3));
    });

    test('Categorizes Tasks and Deadlines correctly', () {
      const taskNote = "Remember to finish the Stage UI system tokens and glassmorphism sprint deliverable by Friday.";
      final result = engine.analyzeNote(taskNote);

      expect(result.categories.contains('tasks'), isTrue);
    });

    test('Categorizes Meeting Discussions', () {
      const meetingNote = "Client sync meeting agenda: discuss mobile deployment, TestFlight distribution, and offline latency benchmarks.";
      final result = engine.analyzeNote(meetingNote);

      expect(result.categories.contains('meeting'), isTrue);
    });
  });

  group('NoteService Integration Tests', () {
    test('createFromVoiceTranscription saves note with AI categories', () {
      final service = NoteService();
      final initialCount = service.allNotes.length;

      final note = service.createFromVoiceTranscription("Brainstorming new startup ideas for spatial audio notes.");

      expect(service.allNotes.length, equals(initialCount + 1));
      expect(note.tags.contains('ideas'), isTrue);
      expect(note.title.isNotEmpty, isTrue);
    });
  });

  group('UI & Widget Smoke Tests', () {
    testWidgets('NoteEchoes loads and displays header and quick actions', (WidgetTester tester) async {
      await tester.pumpWidget(const NoteEchoesApp());
      await tester.pumpAndSettle();

      expect(find.text('notechoes'), findsWidgets);
      expect(find.text('Action Button Siri Note'), findsOneWidget);
      expect(find.text('Voice Mode'), findsOneWidget);
      expect(find.text('Write Note'), findsOneWidget);
    });
  });
}
