const String naira = '₦';

/// 23000 -> "₦23,000"
String money(num value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${negative ? '-' : ''}$naira$buf';
}

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];
const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String dayLabel(DateTime d, [DateTime? now]) {
  final today = dayOnly(now ?? DateTime.now());
  final diff = today.difference(dayOnly(d)).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

String timeLabel(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
}

String relativeTime(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  return '${d.day} ${_months[d.month - 1]}';
}

String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

String hm(int minutesSinceMidnight) {
  final h24 = minutesSinceMidnight ~/ 60;
  final m = minutesSinceMidnight % 60;
  final h = h24 % 12 == 0 ? 12 : h24 % 12;
  final suffix = h24 < 12 ? 'am' : 'pm';
  return m == 0 ? '$h$suffix' : '$h:${m.toString().padLeft(2, '0')}$suffix';
}
