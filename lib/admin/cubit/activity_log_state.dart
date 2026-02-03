import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/admin/data/models/activity_log.dart';
import 'package:frontend/admin/data/models/paginated_response.dart';

part 'activity_log_state.freezed.dart';

/// Filters for activity log queries.
@freezed
class ActivityLogFilters with _$ActivityLogFilters {
  const factory ActivityLogFilters({
    String? dateFrom,
    String? dateTo,
    int? userId,
    String? event,
  }) = _ActivityLogFilters;

  /// Returns true if any filter is active.
  const ActivityLogFilters._();

  bool get hasActiveFilters =>
      dateFrom != null || dateTo != null || userId != null || event != null;

  int get activeFilterCount {
    var count = 0;
    if (dateFrom != null || dateTo != null) count++;
    if (userId != null) count++;
    if (event != null) count++;
    return count;
  }
}

/// State for the activity log list.
@freezed
sealed class ActivityLogState with _$ActivityLogState {
  const factory ActivityLogState.initial() = ActivityLogInitial;

  const factory ActivityLogState.loading() = ActivityLogLoading;

  const factory ActivityLogState.loaded(
    PaginatedResponse<ActivityLog> logs,
    ActivityLogFilters filters,
  ) = ActivityLogLoaded;

  const factory ActivityLogState.loadingMore(
    PaginatedResponse<ActivityLog> logs,
    ActivityLogFilters filters,
  ) = ActivityLogLoadingMore;

  const factory ActivityLogState.error(String message) = ActivityLogError;
}
