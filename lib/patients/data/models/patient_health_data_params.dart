import 'package:flutter/foundation.dart';
import 'package:frontend/core/data/query_params.dart';
import 'package:frontend/core/utils/date_formats.dart';

/// Query parameters for patient health data endpoints with date range filtering.
///
/// Used by doctors/admins to fetch a patient's health data with optional
/// date range filtering.
@immutable
class PatientHealthDataParams extends QueryParams {
  /// Creates patient health data params with optional date range.
  const PatientHealthDataParams({
    this.from,
    this.to,
  });

  /// Creates params with no date filter (fetches recent data).
  const PatientHealthDataParams.noFilter()
      : from = null,
        to = null;

  /// Creates params with a date range filter.
  const PatientHealthDataParams.dateRange({
    required this.from,
    required this.to,
  });

  /// Creates params starting from a specific date.
  const PatientHealthDataParams.fromDate(DateTime this.from) : to = null;

  /// Filter readings from this date onwards (inclusive).
  final DateTime? from;

  /// Filter readings up to this date (inclusive).
  final DateTime? to;

  @override
  Map<String, dynamic> toQueryMap() => {
        if (from != null) 'from': AppDateFormats.toApiDate(from!),
        if (to != null) 'to': AppDateFormats.toApiDate(to!),
      };

  /// Whether this has any date filter applied.
  bool get hasDateFilter => from != null || to != null;

  /// Creates a copy with updated values.
  PatientHealthDataParams copyWith({
    DateTime? from,
    DateTime? to,
    bool clearFrom = false,
    bool clearTo = false,
  }) {
    return PatientHealthDataParams(
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientHealthDataParams &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => Object.hash(from, to);
}
