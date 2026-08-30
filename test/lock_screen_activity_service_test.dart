import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/models/note_model.dart';
import 'package:notechoes_app/services/lock_screen_activity_service.dart';

void main() {
  test(
    'Lock Screen payload retains the full checklist for native rotation',
    () {
      final note = NoteModel(
        noteId: 'long-list',
        title: 'Groceries',
        contentType: NoteContentType.textOnly,
        summarySnippet: 'Eight groceries',
        textContent: 'Groceries',
        createdAt: DateTime.utc(2026, 8, 29),
        tags: const ['tasks'],
        checklist: List.generate(
          8,
          (index) => CheckListItem(
            id: 'item-$index',
            text: 'Item ${index + 1}',
            isCompleted: index == 0,
          ),
        ),
      );

      final payload = LockScreenActivityService.instance.buildPayload(note);
      expect(payload['items'], hasLength(8));
      expect(payload['completed'], 1);
      expect(payload['total'], 8);
    },
  );
}
