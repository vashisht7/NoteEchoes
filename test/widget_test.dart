import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/main.dart';

void main() {
  testWidgets('NoteEchoes loads and displays header', (WidgetTester tester) async {
    await tester.pumpWidget(const NoteEchoesApp());
    await tester.pumpAndSettle();

    expect(find.text('NoteEchoes'), findsWidgets);
    expect(find.text('Welcome to NoteEchoes'), findsOneWidget);
  });
}
