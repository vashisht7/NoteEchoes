import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:notechoes_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'physical iPhone note swipe, table Return, and recording permission bridge',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add Note'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('note_title_field')),
        'Swipe persistence check',
      );
      await tester.fling(
        find.byKey(const ValueKey('note_editor_gesture_surface')),
        const Offset(430, 0),
        1400,
      );
      await tester.pumpAndSettle();
      expect(find.text('Swipe persistence check'), findsOneWidget);

      await tester.tap(find.byTooltip('Add Note'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Insert Table'));
      await tester.pump();
      expect(find.byKey(const ValueKey('table_cell_1_1')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('table_cell_1_1')));
      await tester.enterText(
        find.byKey(const ValueKey('table_cell_1_1')),
        'last cell',
      );
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('table_cell_2_0')), findsOneWidget);

      const speechChannel = MethodChannel('notechoes/offline_speech');
      final permission = await speechChannel.invokeMethod<String>(
        'recordingPermissionStatus',
      );
      expect(permission, anyOf('granted', 'denied', 'undetermined', 'unknown'));
    },
  );
}
