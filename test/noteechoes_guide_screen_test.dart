import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/screens/noteechoes_guide_screen.dart';
import 'package:notechoes_app/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('settings opens the NoteEchoes voice guide', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFFD7192D)),
        ),
        home: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('noteechoes_guide_tile')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('noteechoes_guide_tile')));
    await tester.pumpAndSettle();

    expect(find.byType(NoteEchoesGuideScreen), findsOneWidget);
    expect(find.text('The reliable voice formula'), findsOneWidget);
    expect(find.text('Capture a thought'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guide stays usable on a compact iPhone screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFFD7192D)),
        ),
        home: const NoteEchoesGuideScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NoteEchoes Guide'), findsOneWidget);
    expect(find.textContaining('Speak naturally.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('For the best results'),
      420,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('For the best results'), findsOneWidget);
    expect(find.textContaining('One compact action model'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
