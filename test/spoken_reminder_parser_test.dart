import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/services/spoken_reminder_parser.dart';

void main() {
  test('creates a deterministic future reminder from explicit speech', () {
    final reminder = SpokenReminderParser.parse(
      'Remind me tomorrow at 9 AM to call Ravi',
      now: DateTime(2026, 8, 23, 14),
    );

    expect(reminder, isNotNull);
    expect(reminder!.triggerDate, DateTime(2026, 8, 24, 9));
    expect(reminder.title.toLowerCase(), contains('call ravi'));
  });

  test('supports a short relative reminder for notification testing', () {
    final now = DateTime(2026, 8, 23, 14, 30);
    final reminder = SpokenReminderParser.parse(
      'Remind me in 2 minutes to check the app',
      now: now,
    );
    expect(reminder?.triggerDate, now.add(const Duration(minutes: 2)));
  });

  test('supports the natural one-minute phrase used on iPhone', () {
    final now = DateTime(2026, 8, 26, 10, 15);
    final reminder = SpokenReminderParser.parse(
      'Remind me in one minute to check app',
      now: now,
    );

    expect(reminder, isNotNull);
    expect(reminder!.triggerDate, now.add(const Duration(minutes: 1)));
    expect(reminder.title.toLowerCase(), contains('check app'));
    expect(reminder.title.toLowerCase(), isNot(contains('one minute')));
  });

  test('supports a and compound spoken relative times', () {
    final now = DateTime(2026, 8, 26, 10);
    expect(
      SpokenReminderParser.parse(
        'Remind me in a minute to stand up',
        now: now,
      )?.triggerDate,
      now.add(const Duration(minutes: 1)),
    );
    expect(
      SpokenReminderParser.parse(
        'Remind me in twenty one minutes to leave',
        now: now,
      )?.triggerDate,
      now.add(const Duration(minutes: 21)),
    );
  });

  test('supports natural reminder synonyms', () {
    final now = DateTime(2026, 8, 26, 10);
    for (final speech in const [
      'Ping me in ten minutes to check the build',
      'Notify me in ten minutes to check the build',
      "Don't let me forget in ten minutes to check the build",
      'Set an alarm in ten minutes to check the build',
    ]) {
      final reminder = SpokenReminderParser.parse(speech, now: now);
      expect(
        reminder?.triggerDate,
        now.add(const Duration(minutes: 10)),
        reason: speech,
      );
      expect(
        reminder?.title.toLowerCase(),
        contains('check the build'),
        reason: speech,
      );
    }
  });

  test('does not create a reminder without a specific time', () {
    expect(
      SpokenReminderParser.parse(
        'Remind me later to call Ravi',
        now: DateTime(2026, 8, 23),
      ),
      isNull,
    );
  });
}
