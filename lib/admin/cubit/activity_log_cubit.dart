import 'package:bloc/bloc.dart';
import 'package:frontend/admin/cubit/activity_log_state.dart';
import 'package:frontend/admin/data/admin_repository.dart';
import 'package:frontend/admin/data/models/activity_log.dart';

/// Cubit for managing activity log state.
class ActivityLogCubit extends Cubit<ActivityLogState> {
  ActivityLogCubit({
    required AdminRepository adminRepository,
  })  : _adminRepository = adminRepository,
        super(const ActivityLogState.initial());

  final AdminRepository _adminRepository;

  /// Current filters applied to the log list.
  ActivityLogFilters _currentFilters = const ActivityLogFilters();

  /// Load activity logs with optional filters.
  Future<void> loadLogs({ActivityLogFilters? filters}) async {
    _currentFilters = filters ?? const ActivityLogFilters();
    emit(const ActivityLogState.loading());

    final response = await _adminRepository.getActivityLogs(
      dateFrom: _currentFilters.dateFrom,
      dateTo: _currentFilters.dateTo,
      userId: _currentFilters.userId,
      event: _currentFilters.event,
    );

    response.when(
      success: (logs, _) => emit(ActivityLogState.loaded(logs, _currentFilters)),
      error: (message, _) => emit(ActivityLogState.error(message)),
    );
  }

  /// Load more logs for pagination.
  Future<void> loadMore() async {
    final currentState = state;

    // Can only load more from loaded state
    if (currentState is! ActivityLogLoaded) return;

    final currentLogs = currentState.logs;

    // Check if there are more pages
    if (currentLogs.currentPage >= currentLogs.lastPage) return;

    emit(ActivityLogState.loadingMore(currentLogs, _currentFilters));

    final response = await _adminRepository.getActivityLogs(
      page: currentLogs.currentPage + 1,
      dateFrom: _currentFilters.dateFrom,
      dateTo: _currentFilters.dateTo,
      userId: _currentFilters.userId,
      event: _currentFilters.event,
    );

    response.when(
      success: (newLogs, _) {
        // Merge the new logs with existing ones
        final mergedData = <ActivityLog>[
          ...currentLogs.data,
          ...newLogs.data,
        ];

        final mergedLogs = newLogs.copyWith(data: mergedData);
        emit(ActivityLogState.loaded(mergedLogs, _currentFilters));
      },
      error: (message, _) {
        // On error, revert to loaded state with existing data
        emit(ActivityLogState.loaded(currentLogs, _currentFilters));
      },
    );
  }

  /// Apply new filters and reload logs.
  Future<void> setFilters(ActivityLogFilters filters) async {
    await loadLogs(filters: filters);
  }

  /// Clear all filters and reload logs.
  Future<void> clearFilters() async {
    await loadLogs(filters: const ActivityLogFilters());
  }

  /// Get current filters.
  ActivityLogFilters get currentFilters => _currentFilters;
}
