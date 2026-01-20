import 'package:flutter/material.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

class BloodSugarHistory extends StatelessWidget {
  const BloodSugarHistory({
    required this.readings,
    required this.isLoading,
    this.isLoadingMore = false,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final List<BloodSugarReading> readings;
  final bool isLoading;
  final bool isLoadingMore;
  final void Function(BloodSugarReading reading)? onEdit;
  final void Function(BloodSugarReading reading)? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.bloodSugarHistorySection,
          style: context.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (readings.isEmpty)
          _EmptyState(l10n: l10n)
        else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: readings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final reading = readings[index];
              return _ReadingCard(
                reading: reading,
                l10n: l10n,
                onEdit: onEdit,
                onDelete: onDelete,
              );
            },
          ),
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDataYet,
              style: context.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.addFirstReading,
              style: context.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.reading,
    required this.l10n,
    this.onEdit,
    this.onDelete,
  });

  final BloodSugarReading reading;
  final AppLocalizations l10n;
  final void Function(BloodSugarReading reading)? onEdit;
  final void Function(BloodSugarReading reading)? onDelete;

  bool get _canModify {
    final now = DateTime.now();
    final difference = now.difference(reading.measuredAt);
    return difference.inDays < 7;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');
    final showActions = _canModify && (onEdit != null || onDelete != null);

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${reading.glucoseLevel} ${l10n.mmolLUnit}',
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(reading.measuredAt)} '
                    '${timeFormat.format(reading.measuredAt)}',
                    style: context.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (showActions) ...[
              IconButton(
                onPressed: () => onEdit?.call(reading),
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.editButton,
                iconSize: 20,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => onDelete?.call(reading),
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteButton,
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                color: AppColors.error,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
