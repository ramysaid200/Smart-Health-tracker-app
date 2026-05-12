import 'package:intl/intl.dart';

/// Date and time formatting utilities for Smart Health Tracker
class DateFormatter {
  DateFormatter._();

  /// Format: "Mon, Jan 12"
  static String toDisplayDate(DateTime date) => DateFormat('EEE, MMM d').format(date);

  /// Format: "January 12, 2025"
  static String toLongDate(DateTime date) => DateFormat('MMMM d, yyyy').format(date);

  /// Format: "YYYY-MM-DD" (used as Firestore document IDs)
  static String toDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// Format: "9:15 AM"
  static String toTime(DateTime date) => DateFormat('h:mm a').format(date);

  /// Format: "Jan 2025"
  static String toMonthYear(DateTime date) => DateFormat('MMM yyyy').format(date);

  /// Format: "Mon" (short weekday)
  static String toShortWeekday(DateTime date) => DateFormat('EEE').format(date);

  /// Format: "12" (day of month)
  static String toDayOfMonth(DateTime date) => DateFormat('d').format(date);

  /// Format: "11:30 PM"
  static String toShortTime(DateTime date) => DateFormat('h:mm a').format(date);

  /// Format: "7h 23m" from a duration in minutes
  static String durationToHoursMinutes(double minutes) {
    final int h = minutes ~/ 60;
    final int m = (minutes % 60).round();
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Relative time: "2 hours ago", "Just now", "Yesterday", etc.
  static String toRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return toDisplayDate(date);
  }

  /// Get the past 7 days as a list of DateTime
  static List<DateTime> getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
  }

  /// Get the past N days
  static List<DateTime> getLastNDays(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) => now.subtract(Duration(days: n - 1 - i)));
  }

  /// Get start and end of current week (Mon–Sun)
  static (DateTime, DateTime) getCurrentWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return (
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    );
  }

  /// Get start and end of current month
  static (DateTime, DateTime) getCurrentMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return (start, end);
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Get the member since label from a DateTime
  static String toMemberSince(DateTime date) => DateFormat('MMM yyyy').format(date);

  /// Parse a date key string back to DateTime
  static DateTime fromDateKey(String key) => DateFormat('yyyy-MM-dd').parse(key);

  /// Format duration from bedtime to wake time
  static String sleepDuration(DateTime bedtime, DateTime wakeTime) {
    final duration = wakeTime.difference(bedtime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  /// Get greeting based on time of day
  static String getGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    return '$greeting, $name! 👋';
  }
}
