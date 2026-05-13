import 'package:intl/intl.dart';

/// Date range and utility service for health data queries
class DateService {
  DateService._();
  static final DateService instance = DateService._();

  /// Today's date key (YYYY-MM-DD)
  String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Yesterday's date key
  String yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(yesterday);
  }

  /// Today as DateTime (midnight)
  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Start and end of current week (Monday–Sunday)
  (DateTime start, DateTime end) weekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return (start, end);
  }

  /// Start and end of current month
  (DateTime start, DateTime end) monthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return (start, end);
  }

  /// Start and end of last N months
  (DateTime start, DateTime end) lastNMonthsRange(int months) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - months, now.day);
    return (start, now);
  }

  /// Start and end of current year
  (DateTime start, DateTime end) yearRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31, 23, 59, 59);
    return (start, end);
  }

  /// Get date keys for the past 7 days
  List<String> last7DayKeys() {
    return List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      return DateFormat('yyyy-MM-dd').format(date);
    });
  }

  /// Format DateTime for Firestore storage
  DateTime forFirestore(DateTime dt) => dt.toUtc();

  /// Get the short label for a date key
  String shortLabelForKey(String dateKey) {
    final dt = DateFormat('yyyy-MM-dd').parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE').format(dt);
  }
}
