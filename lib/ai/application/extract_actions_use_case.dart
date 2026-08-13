// extract_actions_use_case.dart
// Extracts confirmed calendar events/reminders from NoteAnalysisResult
// and stages them as SuggestedActions awaiting user confirmation.

import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/drift.dart' as drift;
import '../domain/note_analysis.dart';
import '../domain/suggested_action.dart';
import '../providers/calendar_provider.dart';
import '../infrastructure/ai_database.dart';

class ExtractActionsUseCase {
  final AiDatabase database;
  final CalendarProvider calendarProvider;

  ExtractActionsUseCase(this.database, this.calendarProvider);

  Future<List<SuggestedAction>> extractAndSave(
      NoteAnalysisResult analysis) async {
    const uuid = Uuid();
    final actions = <SuggestedAction>[];
    final now = DateTime.now();

    // Action items → task actions
    for (final item in analysis.actionItems) {
      actions.add(SuggestedAction(
        id: uuid.v4(),
        noteId: analysis.noteId,
        actionType: SuggestedActionType.actionItem,
        title: item.task,
        details: item.toJson(),
        evidenceText: item.evidenceText,
        confidence: item.confidence,
        createdAt: now,
      ));
    }

    // Calendar events
    for (final event in analysis.events) {
      actions.add(SuggestedAction(
        id: uuid.v4(),
        noteId: analysis.noteId,
        actionType: SuggestedActionType.calendarEvent,
        title: event.title,
        details: event.toJson(),
        evidenceText: event.evidenceText,
        confidence: event.confidence,
        createdAt: now,
      ));
    }

    // Reminders
    for (final reminder in analysis.reminders) {
      actions.add(SuggestedAction(
        id: uuid.v4(),
        noteId: analysis.noteId,
        actionType: SuggestedActionType.reminder,
        title: reminder.title,
        details: reminder.toJson(),
        evidenceText: reminder.evidenceText,
        confidence: reminder.confidence,
        createdAt: now,
      ));
    }

    // Travel details
    for (final travel in analysis.travelDetails) {
      actions.add(SuggestedAction(
        id: uuid.v4(),
        noteId: analysis.noteId,
        actionType: SuggestedActionType.travelDetail,
        title: 'Travel to ${travel.destination}',
        details: travel.toJson(),
        evidenceText: travel.evidenceText,
        confidence: 0.7,
        createdAt: now,
      ));
    }

    // Persist all as 'pending'
    for (final action in actions) {
      await database.upsertSuggestedAction(
        SuggestedActionsTableCompanion(
          id: Value(action.id),
          noteId: Value(action.noteId),
          actionType: Value(action.actionType.name),
          title: Value(action.title),
          detailsJson: Value(jsonEncode(action.details)),
          evidenceText: Value(action.evidenceText),
          confidence: Value(action.confidence),
          status: Value(action.status.name),
          createdAt: Value(action.createdAt.millisecondsSinceEpoch),
        ),
      );
    }

    return actions;
  }

  Future<bool> confirmAction(String actionId) async {
    final rows = await database
        .customSelect(
          'SELECT * FROM suggested_actions WHERE id = ?',
          variables: [drift.Variable.withString(actionId)],
        )
        .get();

    if (rows.isEmpty) return false;
    final row = rows.first.data;

    final actionTypeStr = row['action_type'] as String? ?? '';
    bool success = false;

    try {
      if (actionTypeStr == SuggestedActionType.calendarEvent.name) {
        final details =
            jsonDecode(row['details_json'] as String? ?? '{}')
                as Map<String, dynamic>;
        final event = CalendarEvent.fromJson(details);
        final (result, _) = await calendarProvider.createEvent(event);
        success = result == CalendarWriteResult.success;
      } else if (actionTypeStr == SuggestedActionType.reminder.name) {
        final details =
            jsonDecode(row['details_json'] as String? ?? '{}')
                as Map<String, dynamic>;
        final reminder = Reminder.fromJson(details);
        final (result, _) = await calendarProvider.createReminder(reminder);
        success = result == CalendarWriteResult.success;
      } else {
        // Task / travel — mark confirmed without a platform write.
        success = true;
      }
    } catch (_) {
      success = false;
    }

    await database.updateActionStatus(
      actionId,
      success
          ? SuggestedActionStatus.confirmed.name
          : SuggestedActionStatus.failed.name,
    );
    return success;
  }

  Future<void> dismissAction(String actionId) async {
    await database.updateActionStatus(
        actionId, SuggestedActionStatus.dismissed.name);
  }
}
