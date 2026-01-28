import 'package:flutter/foundation.dart';
import 'package:frontend/core/data/query_params.dart';

/// Filter options for patient list.
enum PatientFilter {
  all,
  active,
  inactive;

  /// Returns the API value for this filter.
  String toApiValue() => name;
}

/// Query parameters for patient list endpoints with search and filtering.
///
/// Extends [QueryParams] with optional search term and status filter.
@immutable
class PatientListParams extends QueryParams {
  /// Creates patient list params with optional pagination, search, and filter.
  const PatientListParams({
    this.limit,
    this.offset,
    this.search,
    this.filter = PatientFilter.all,
  });

  /// Creates params for the first page with default limit and no filters.
  const PatientListParams.firstPage()
      : limit = defaultPageSize,
        offset = null,
        search = null,
        filter = PatientFilter.all;

  /// Creates params for the next page based on current item count.
  const PatientListParams.nextPage(
    int currentCount, {
    this.search,
    this.filter = PatientFilter.all,
  })  : limit = defaultPageSize,
        offset = currentCount;

  /// Creates params with search/filter applied (resets to first page).
  const PatientListParams.withFilters({
    this.search,
    this.filter = PatientFilter.all,
  })  : limit = defaultPageSize,
        offset = null;

  /// Default page size used across the app.
  static const int defaultPageSize = 20;

  /// Maximum number of items to return.
  final int? limit;

  /// Number of items to skip before returning results.
  final int? offset;

  /// Search term for filtering by name, surname, or patient code.
  final String? search;

  /// Filter by patient status (all, active, inactive).
  final PatientFilter filter;

  @override
  Map<String, dynamic> toQueryMap() => {
        if (limit != null) 'limit': limit,
        if (offset != null && offset! > 0) 'offset': offset,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (filter != PatientFilter.all) 'filter': filter.toApiValue(),
      };

  /// Whether this represents a request for more items (not first page).
  bool get isLoadingMore => offset != null && offset! > 0;

  /// Returns true if any search/filter is active.
  bool get hasActiveFilters =>
      (search != null && search!.isNotEmpty) || filter != PatientFilter.all;

  /// Creates a copy with updated values.
  PatientListParams copyWith({
    int? limit,
    int? offset,
    String? search,
    PatientFilter? filter,
    bool clearSearch = false,
    bool clearOffset = false,
  }) {
    return PatientListParams(
      limit: limit ?? this.limit,
      offset: clearOffset ? null : (offset ?? this.offset),
      search: clearSearch ? null : (search ?? this.search),
      filter: filter ?? this.filter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientListParams &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset &&
          search == other.search &&
          filter == other.filter;

  @override
  int get hashCode => Object.hash(limit, offset, search, filter);
}
