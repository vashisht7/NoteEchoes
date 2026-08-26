// date_formatter.dart
// Human-readable date and timestamp formatting for NoteEchoes cards and headers.

String formatNoteTimestamp(DateTime dt) {
  dt = dt.toLocal();
  final now = DateTime.now();
  final isToday =
      now.year == dt.year && now.month == dt.month && now.day == dt.day;

  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday =
      yesterday.year == dt.year &&
      yesterday.month == dt.month &&
      yesterday.day == dt.day;

  final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
  final minute = dt.minute.toString().padLeft(2, '0');
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  final timeStr = '$hour:$minute $amPm';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  if (isToday) {
    return 'Today, $timeStr';
  } else if (isYesterday) {
    return 'Yesterday, $timeStr';
  } else if (now.year == dt.year) {
    return '${months[dt.month - 1]} ${dt.day}, $timeStr';
  } else {
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

String formatNoteDateShort(DateTime dt) {
  dt = dt.toLocal();
  final now = DateTime.now();
  if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}';
}
