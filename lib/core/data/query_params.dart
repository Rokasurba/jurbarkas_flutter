/// Base class for type-safe query parameters.
///
/// Extend this class to create specific parameter sets for API calls.
/// Use [toQueryMap] to convert parameters to a map for HTTP requests.
///
/// Example:
/// ```dart
/// class MyParams extends QueryParams {
///   final String? search;
///   final PaginationParams pagination;
///
///   MyParams({this.search, this.pagination = const PaginationParams()});
///
///   @override
///   Map<String, dynamic> toQueryMap() => {
///     if (search != null) 'search': search,
///     ...pagination.toQueryMap(),
///   };
/// }
/// ```
abstract class QueryParams {
  const QueryParams();

  /// Converts parameters to a map suitable for HTTP query parameters.
  ///
  /// Returns an empty map if no parameters are set.
  /// Only includes non-null values with meaningful defaults.
  Map<String, dynamic> toQueryMap();

  /// Returns null if the map is empty, otherwise returns the map.
  ///
  /// Useful for passing to HTTP clients that accept nullable query params.
  Map<String, dynamic>? toQueryMapOrNull() {
    final map = toQueryMap();
    return map.isEmpty ? null : map;
  }
}

/// Pagination parameters for list endpoints.
///
/// Provides [limit] for page size and [offset] for cursor position.
class PaginationParams extends QueryParams {
  /// Creates pagination params with optional limit and offset.
  const PaginationParams({
    this.limit,
    this.offset,
  });

  /// Creates params for the first page with default limit.
  const PaginationParams.firstPage()
      : limit = defaultPageSize,
        offset = null;

  /// Creates params for the next page based on current item count.
  PaginationParams.nextPage(int currentCount)
      : limit = defaultPageSize,
        offset = currentCount;

  /// Default page size used across the app.
  static const int defaultPageSize = 20;

  /// Maximum number of items to return.
  final int? limit;

  /// Number of items to skip before returning results.
  final int? offset;

  @override
  Map<String, dynamic> toQueryMap() => {
        if (limit != null) 'limit': limit,
        if (offset != null && offset! > 0) 'offset': offset,
      };

  /// Whether this represents a request for more items (not first page).
  bool get isLoadingMore => offset != null && offset! > 0;
}
