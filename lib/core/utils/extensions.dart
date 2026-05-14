import 'package:intl/intl.dart';

/// Dart extensions for common data transformations
extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase {
    return split(' ').map((w) => w.capitalize).join(' ');
  }

  bool get isValidEmail =>
      RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(trim());

  double? get toDouble => double.tryParse(trim());
  int? get toInt => int.tryParse(trim());

  String get snakeToTitle => split('_').map((w) => w.capitalize).join(' ');
}

extension DateTimeExtensions on DateTime {
  String get toDateKey => DateFormat('yyyy-MM-dd').format(this);
  String get toDisplayDate => DateFormat('EEE, MMM d').format(this);
  String get toShortTime => DateFormat('h:mm a').format(this);
  String get toLongDate => DateFormat('MMMM d, yyyy').format(this);
  String get toMonthYear => DateFormat('MMM yyyy').format(this);
  String get toShortWeekday => DateFormat('EEE').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  String get relativeLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return toDisplayDate;
  }
}

extension DoubleExtensions on double {
  String toFixed(int digits) => toStringAsFixed(digits);
  String get toKg => '${toStringAsFixed(1)} kg';
  String get toLbs => '${toStringAsFixed(1)} lbs';
  String get toKcal => '${toStringAsFixed(0)} kcal';
  String get toBMI => toStringAsFixed(1);

  /// Progress percentage clamped to 0–1
  double get clampedProgress => clamp(0.0, 1.0).toDouble();
}

extension IntExtensions on int {
  String get toTimeString {
    final h = this ~/ 60;
    final m = this % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String get stepsFormatted {
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}k';
    return toString();
  }
}

extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}

extension ColorExtensions on double {
  /// Convert a ratio (0.0–1.0) to a readable percentage string
  String get toPercent => '${(this * 100).toStringAsFixed(0)}%';
}
