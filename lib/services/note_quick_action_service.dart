import 'package:url_launcher/url_launcher.dart';

import '../models/note_model.dart';

enum NoteQuickActionKind { reminder, checklist, email, message, note }

class NoteQuickActionService {
  const NoteQuickActionService._();

  static NoteQuickActionKind classify(NoteModel note) {
    final tags = note.tags.map((tag) => tag.toLowerCase()).toSet();
    if (tags.any((tag) => tag.contains('reminder'))) {
      return NoteQuickActionKind.reminder;
    }
    if (note.checklist.isNotEmpty ||
        tags.any((tag) => tag == 'tasks' || tag.contains('checklist'))) {
      return NoteQuickActionKind.checklist;
    }
    if (tags.any((tag) => tag == 'email' || tag == 'email_draft')) {
      return NoteQuickActionKind.email;
    }
    if (tags.any((tag) => tag == 'message' || tag == 'message_draft')) {
      return NoteQuickActionKind.message;
    }
    return NoteQuickActionKind.note;
  }

  static Future<bool> launchComposer(NoteModel note) async {
    final kind = classify(note);
    final body = _draftBody(note.textContent.trim());
    if (kind == NoteQuickActionKind.message) {
      final phone = RegExp(r'\+?\d[\d\s().-]{6,}\d')
          .firstMatch(note.textContent)
          ?.group(0)
          ?.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri.parse(
        'sms:${phone ?? ''}&body=${Uri.encodeComponent(body)}',
      );
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (kind == NoteQuickActionKind.email) {
      final address = RegExp(
        r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
        caseSensitive: false,
      ).firstMatch(note.textContent)?.group(0);
      final uri = Uri(
        scheme: 'mailto',
        path: address ?? '',
        queryParameters: {'subject': note.title, 'body': body},
      );
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static String _draftBody(String value) {
    final match = RegExp(
      r'\b(?:message|text|sms|whatsapp|email|e-mail|mail)\b[\s\S]*?\b(?:that|saying)\s+([\s\S]+)$',
      caseSensitive: false,
    ).firstMatch(value);
    return (match?.group(1) ?? value).trim().replaceFirst(
      RegExp(r'[.!?]+$'),
      '',
    );
  }
}
