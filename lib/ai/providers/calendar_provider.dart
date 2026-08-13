// calendar_provider.dart
// Abstract interface for write-only calendar and reminder integration.
// Implemented on iOS by AppleCalendarBridge; on Android it can be
// implemented via the android.provider.CalendarContract content provider.
// The base implementation is a no-op stub.

import '../domain/note_analysis.dart';

enum CalendarWriteResult {
  success,
  permissionDenied,
  notAvailable,
  failed,
}

/// Abstract write-only calendar/reminder integration.
/// All writes require prior explicit user confirmation at the UI layer.
abstract class CalendarProvider {
  /// Whether the platform supports calendar integration.
  bool get isAvailable;

  /// Request calendar and reminder permissions.
  /// Returns true if all required permissions granted.
  Future<bool> requestPermissions();

  /// Create a calendar event. Returns the platform event identifier.
  Future<(CalendarWriteResult, String?)> createEvent(CalendarEvent event);

  /// Create a reminder.
  Future<(CalendarWriteResult, String?)> createReminder(Reminder reminder);

  /// Delete a previously created event by platform ID.
  Future<CalendarWriteResult> deleteEvent(String platformEventId);

  /// Delete a previously created reminder by platform ID.
  Future<CalendarWriteResult> deleteReminder(String platformReminderId);
}

/// No-op stub used on unsupported platforms.
class NoOpCalendarProvider implements CalendarProvider {
  const NoOpCalendarProvider();

  @override
  bool get isAvailable => false;

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<(CalendarWriteResult, String?)> createEvent(
      CalendarEvent event) async =>
      (CalendarWriteResult.notAvailable, null);

  @override
  Future<(CalendarWriteResult, String?)> createReminder(
      Reminder reminder) async =>
      (CalendarWriteResult.notAvailable, null);

  @override
  Future<CalendarWriteResult> deleteEvent(String platformEventId) async =>
      CalendarWriteResult.notAvailable;

  @override
  Future<CalendarWriteResult> deleteReminder(
      String platformReminderId) async =>
      CalendarWriteResult.notAvailable;
}
