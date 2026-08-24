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
