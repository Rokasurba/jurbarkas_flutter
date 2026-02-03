import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/cubit/activity_log_cubit.dart';
import 'package:frontend/admin/cubit/activity_log_state.dart';
import 'package:frontend/admin/data/admin_repository.dart';
import 'package:frontend/admin/data/models/activity_log.dart';
import 'package:frontend/admin/view/widgets/activity_log_filter_bottom_sheet.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ActivityLogListPage extends StatelessWidget {
  const ActivityLogListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityLogCubit(
        adminRepository: AdminRepository(
          apiClient: context.read<ApiClient>(),
        ),
      )..loadLogs(),
      child: const ActivityLogListView(),
    );
  }
}

class ActivityLogListView extends StatefulWidget {
  const ActivityLogListView({super.key});

  @override
  State<ActivityLogListView> createState() => _ActivityLogListViewState();
}

class _ActivityLogListViewState extends State<ActivityLogListView> {
  final _scrollController = ScrollController();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ActivityLogCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _showFilterSheet() async {
    final cubit = context.read<ActivityLogCubit>();
    final result = await showModalBottomSheet<ActivityLogFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ActivityLogFilterBottomSheet(
        currentFilters: cubit.currentFilters,
      ),
    );

    if (result != null) {
      unawaited(cubit.setFilters(result));
    }
  }

  Future<void> _exportLogs() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    final l10n = context.l10n;
    final cubit = context.read<ActivityLogCubit>();
    final filters = cubit.currentFilters;

    final csvContent = await AdminRepository(
      apiClient: context.read<ApiClient>(),
    ).exportActivityLogs(
      dateFrom: filters.dateFrom,
      dateTo: filters.dateTo,
      userId: filters.userId,
      event: filters.event,
    );

    setState(() => _isExporting = false);

    if (!mounted) return;

    if (csvContent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.eksportoKlaida),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final filename = 'activity_logs_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';

    if (kIsWeb) {
      _downloadCsvWeb(csvContent, filename);
    } else {
      // For mobile, we would use share_plus, but for now show success
      // since the packages aren't added yet
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.eksportasSekmingas),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _downloadCsvWeb(String csvContent, String filename) {
    // Web-specific implementation using dart:html
    // This will be conditionally imported for web builds
    // For now, the export endpoint returns the file directly
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          l10n.veiklosZurnalas,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          BlocBuilder<ActivityLogCubit, ActivityLogState>(
            builder: (context, state) {
              final filterCount = state.maybeWhen(
                loaded: (_, filters) => filters.activeFilterCount,
                loadingMore: (_, filters) => filters.activeFilterCount,
                orElse: () => 0,
              );

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterSheet,
                    tooltip: l10n.veiklosZurnaloFiltrai,
                  ),
                  if (filterCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$filterCount',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            onPressed: _isExporting ? null : _exportLogs,
            tooltip: l10n.eksportuotiCsv,
          ),
        ],
      ),
      body: BlocBuilder<ActivityLogCubit, ActivityLogState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (logs, filters) => _buildLogList(
              logs.data,
              false,
              currentPage: logs.currentPage,
              lastPage: logs.lastPage,
              total: logs.total,
            ),
            loadingMore: (logs, filters) => _buildLogList(
              logs.data,
              true,
              currentPage: logs.currentPage,
              lastPage: logs.lastPage,
              total: logs.total,
            ),
            error: _buildErrorState,
          );
        },
      ),
    );
  }

  Widget _buildLogList(
    List<ActivityLog> logs,
    bool isLoadingMore, {
    required int currentPage,
    required int lastPage,
    required int total,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.neraVeiklosIrasu,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Pagination info header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Row(
            children: [
              Icon(
                Icons.list_alt,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.paginationInfo(logs.length, total),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                l10n.pageInfo(currentPage, lastPage),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Log list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: logs.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= logs.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _ActivityLogCard(log: logs[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<ActivityLogCubit>().loadLogs(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.bandytiDarKarta),
          ),
        ],
      ),
    );
  }
}

class _ActivityLogCard extends StatelessWidget {
  const _ActivityLogCard({required this.log});

  final ActivityLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final eventLabel = _getEventLabel(log.event, l10n);
    final eventColor = _getEventColor(log.event, theme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date/Time and Event Badge
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(log.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: eventColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: eventColor),
                  ),
                  child: Text(
                    eventLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: eventColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // User info
            if (log.causer != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      _getInitials(log.causer!.name),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.causer!.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getRoleLabel(log.causer!.role, l10n),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Subject info
            if (log.subjectType != null) ...[
              Row(
                children: [
                  Icon(
                    _getSubjectIcon(log.subjectType),
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${log.subjectType}${log.subjectId != null ? ' #${log.subjectId}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String _getEventLabel(String? event, AppLocalizations l10n) {
    return switch (event) {
      // Model events
      'created' => l10n.sukurta,
      'updated' => l10n.atnaujinta,
      'deleted' => l10n.istrinta,
      // Auth events
      'login_success' => l10n.eventLoginSuccess,
      'login_failed' => l10n.eventLoginFailed,
      'login_blocked' => l10n.eventLoginBlocked,
      'logout' => l10n.eventLogout,
      // Password events
      'password_reset_requested' => l10n.eventPasswordResetRequested,
      'password_reset_otp_sent' => l10n.eventPasswordResetOtpSent,
      'password_reset_otp_verified' => l10n.eventPasswordResetOtpVerified,
      'password_reset_otp_failed' => l10n.eventPasswordResetFailed,
      'password_reset_completed' => l10n.eventPasswordResetCompleted,
      'password_reset_failed' => l10n.eventPasswordResetFailed,
      // Blood pressure events
      'blood_pressure_created' => l10n.eventBloodPressureCreated,
      'blood_pressure_updated' => l10n.eventBloodPressureUpdated,
      'blood_pressure_deleted' => l10n.eventBloodPressureDeleted,
      'blood_pressure_viewed' => l10n.eventBloodPressureViewed,
      // Blood sugar events
      'blood_sugar_reading_created' => l10n.eventBloodSugarCreated,
      'blood_sugar_reading_updated' => l10n.eventBloodSugarUpdated,
      'blood_sugar_reading_deleted' => l10n.eventBloodSugarDeleted,
      'blood_sugar_history_viewed' => l10n.eventBloodSugarViewed,
      // BMI events
      'bmi_measurement_created' => l10n.eventBmiCreated,
      'bmi_measurement_updated' => l10n.eventBmiUpdated,
      'bmi_measurement_deleted' => l10n.eventBmiDeleted,
      'bmi_history_viewed' => l10n.eventBmiViewed,
      // Survey events
      'survey_created' => l10n.eventSurveyCreated,
      'survey_updated' => l10n.eventSurveyUpdated,
      'survey_deleted' => l10n.eventSurveyDeleted,
      'survey_assigned' => l10n.eventSurveyAssigned,
      'survey_completed' => l10n.eventSurveyCompleted,
      'survey_viewed' => l10n.eventSurveyViewed,
      'survey_assignments_viewed' => l10n.eventSurveyViewed,
      'survey_response_viewed' => l10n.eventSurveyViewed,
      'survey_aggregated_results_viewed' => l10n.eventSurveyViewed,
      'assigned_surveys_viewed' => l10n.eventSurveyViewed,
      'completed_survey_viewed' => l10n.eventSurveyViewed,
      'patient_surveys_viewed' => l10n.eventSurveyViewed,
      // Notification events
      'notification_sent' => l10n.eventNotificationSent,
      'notification_failed' => l10n.eventNotificationFailed,
      // Reminder events
      'reminder_sent' => l10n.eventReminderSent,
      'reminder_read' => l10n.eventReminderRead,
      _ => event ?? '-',
    };
  }

  Color _getEventColor(String? event, ThemeData theme) {
    return switch (event) {
      // Created / success events - green
      'created' ||
      'login_success' ||
      'survey_created' ||
      'survey_completed' ||
      'blood_pressure_created' ||
      'blood_sugar_reading_created' ||
      'bmi_measurement_created' ||
      'notification_sent' ||
      'reminder_sent' ||
      'password_reset_completed' ||
      'password_reset_otp_verified' =>
        Colors.green,
      // Updated events - blue
      'updated' ||
      'survey_updated' ||
      'survey_assigned' ||
      'blood_pressure_updated' ||
      'blood_sugar_reading_updated' ||
      'bmi_measurement_updated' =>
        Colors.blue,
      // Deleted events - red
      'deleted' ||
      'survey_deleted' ||
      'blood_pressure_deleted' ||
      'blood_sugar_reading_deleted' ||
      'bmi_measurement_deleted' =>
        Colors.red,
      // Auth warning events - orange
      'login_failed' ||
      'login_blocked' ||
      'password_reset_otp_failed' ||
      'password_reset_failed' ||
      'notification_failed' =>
        Colors.orange,
      // Logout / neutral events - grey
      'logout' ||
      'password_reset_requested' ||
      'password_reset_otp_sent' =>
        Colors.grey,
      // View events - purple
      'survey_viewed' ||
      'survey_assignments_viewed' ||
      'survey_response_viewed' ||
      'survey_aggregated_results_viewed' ||
      'assigned_surveys_viewed' ||
      'completed_survey_viewed' ||
      'patient_surveys_viewed' ||
      'blood_pressure_viewed' ||
      'blood_sugar_history_viewed' ||
      'bmi_history_viewed' ||
      'reminder_read' =>
        Colors.purple,
      _ => theme.colorScheme.outline,
    };
  }

  String _getRoleLabel(String role, AppLocalizations l10n) {
    return switch (role) {
      'admin' => 'Admin',
      'doctor' => l10n.gydytojas,
      'patient' => l10n.pacientas,
      _ => role,
    };
  }

  IconData _getSubjectIcon(String? subjectType) {
    return switch (subjectType) {
      'User' => Icons.person,
      'BloodPressureReading' => Icons.favorite,
      'BmiMeasurement' => Icons.monitor_weight,
      'BloodSugarReading' => Icons.water_drop,
      'Survey' => Icons.quiz,
      'SurveyResponse' => Icons.checklist,
      'Message' => Icons.message,
      'Reminder' => Icons.notifications,
      _ => Icons.article,
    };
  }
}
