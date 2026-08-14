// note_detail_sheet.dart
// Backward compatibility wrapper directing to NoteDetailScreen.

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'note_detail_screen.dart';

export 'note_detail_screen.dart';

class NoteDetailSheet extends StatelessWidget {
  final NoteModel? existingNote;

  const NoteDetailSheet({super.key, this.existingNote});

  @override
  Widget build(BuildContext context) {
    return NoteDetailScreen(existingNote: existingNote);
  }
}
