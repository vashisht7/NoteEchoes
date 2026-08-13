import 'dart:io';
import 'package:flutter/services.dart';
import '../../ai/domain/note_analysis.dart';
import '../../ai/providers/calendar_provider.dart';

class AppleCalendarBridge implements CalendarProvider {
  static const MethodChannel _channel = MethodChannel('notechoes/calendar');

  @override
  bool get isAvailable => Platform.isIOS;

  @override
  Future<bool> requestPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermissions');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<(CalendarWriteResult, String?)> createEvent(
    CalendarEvent event,
  ) async {
    try {
      final result =
          await _channel.invokeMethod<String>('createEvent', event.toJson());
      if (result != null) {
        return (CalendarWriteResult.success, result);
      }
      return (CalendarWriteResult.failed, null);
    } catch (e) {
      return (CalendarWriteResult.failed, null);
    }
  }

  @override
  Future<(CalendarWriteResult, String?)> createReminder(
    Reminder reminder,
  ) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'createReminder',
        reminder.toJson(),
      );
      if (result != null) {
        return (CalendarWriteResult.success, result);
      }
      return (CalendarWriteResult.failed, null);
    } catch (e) {
      return (CalendarWriteResult.failed, null);
    }
  }

  @override
  Future<CalendarWriteResult> deleteEvent(String platformEventId) async {
    try {
      await _channel.invokeMethod('deleteEvent', {'id': platformEventId});
      return CalendarWriteResult.success;
    } catch (e) {
      return CalendarWriteResult.failed;
    }
  }

  @override
  Future<CalendarWriteResult> deleteReminder(String platformReminderId) async {
    try {
      await _channel.invokeMethod('deleteReminder', {'id': platformReminderId});
      return CalendarWriteResult.success;
    } catch (e) {
      return CalendarWriteResult.failed;
    }
  }
}
