import 'package:intl/intl.dart';

/// Centralized date and time formats used across the application.
///
/// All date/time formatting should use these constants to ensure consistency.
abstract class AppDateFormats {
  AppDateFormats._();

  /// Standard date format: 2026-01-23
  static final DateFormat date = DateFormat('yyyy-MM-dd');

  /// Standard time format: 14:30
  static final DateFormat time = DateFormat('HH:mm');

  /// Short date for charts: 01/23
  static final DateFormat chartDate = DateFormat('MM/dd');

  /// Chart tooltip format: 01/23 14:30
  static final DateFormat chartTooltip = DateFormat('MM/dd HH:mm');

  /// Formats a DateTime to ISO date string (YYYY-MM-DD) for API requests.
  static String toApiDate(DateTime date) =>
      date.toIso8601String().split('T').first;
}

/// Extension methods for DateTime formatting.
extension DateTimeFormatting on DateTime {
  /// Formats as 2026-01-23
  String toDateString() => AppDateFormats.date.format(this);

  /// Formats as 14:30
  String toTimeString() => AppDateFormats.time.format(this);

  /// Formats as 01/23
  String toChartDateString() => AppDateFormats.chartDate.format(this);

  /// Formats as 01/23 14:30
  String toChartTooltipString() => AppDateFormats.chartTooltip.format(this);

  /// Formats as 2026-01-23 for API requests.
  String toApiDateString() => AppDateFormats.toApiDate(this);
}
