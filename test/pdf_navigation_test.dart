import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/models/note_model.dart';
import 'package:notechoes_app/screens/note_detail_screen.dart';
import 'package:notechoes_app/services/note_service.dart';
import 'package:notechoes_app/services/note_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    NoteService().clearNotesForTesting();
    await NoteStorageService().useInMemoryDatabaseForTesting();
  });

  testWidgets('PDF opens in reader and returns to its note', (tester) async {
    const missingPdfPath = '/tmp/notechoes-reader-test-missing.pdf';
    final note = NoteModel(
      noteId: 'pdf-navigation-note',
      title: 'Project brief',
      contentType: NoteContentType.richMedia,
      summarySnippet: 'Attached PDF',
      textContent: 'Review this document.',
      createdAt: DateTime.utc(2026, 8, 17),
      mediaAssets: const [
        MediaAsset(
          type: MediaAssetType.pdf,
          url: missingPdfPath,
          caption: 'brief.pdf',
          pageCount: 3,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => NoteDetailScreen(existingNote: note),
                  ),
                ),
                child: const Text('Open note'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open note'));
    await tester.pumpAndSettle();
    expect(find.text('Project brief'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('pdf_attachment_$missingPdfPath')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pdf_reader_screen')), findsOneWidget);
    expect(find.text('PDF not found'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to note'));
    await tester.pumpAndSettle();
    expect(find.text('Project brief'), findsOneWidget);

    expect(find.byKey(const ValueKey('note_back_button')), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(NoteDetailScreen))).canPop(),
      isTrue,
    );
  });
}
