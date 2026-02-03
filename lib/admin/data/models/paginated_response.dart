import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_response.freezed.dart';
part 'paginated_response.g.dart';

/// Generic paginated response model for Laravel pagination.
///
/// Usage:
/// ```dart
/// final response = PaginatedResponse.fromJson(
///   json,
///   (item) => User.fromJson(item as Map<String, dynamic>),
/// );
/// ```
@Freezed(genericArgumentFactories: true)
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> data,
    @JsonKey(name: 'current_page') required int currentPage,
    @JsonKey(name: 'last_page') required int lastPage,
    required int total,
    @JsonKey(name: 'per_page') required int perPage,
  }) = _PaginatedResponse<T>;

  const PaginatedResponse._();

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  /// Returns true if there are more pages to load.
  bool get hasMore => currentPage < lastPage;
}
