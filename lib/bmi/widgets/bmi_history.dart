import 'package:flutter/material.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

class BmiHistory extends StatelessWidget {
  const BmiHistory({
    required this.measurements,
    required this.isLoading,
    this.isLoadingMore = false,
    super.key,
  });

  final List<BmiMeasurement> measurements;
  final bool isLoading;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.bmiHistorySection,
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
        else if (measurements.isEmpty)
          _EmptyState(l10n: l10n)
        else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: measurements.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final measurement = measurements[index];
              return _MeasurementCard(measurement: measurement, l10n: l10n);
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.monitor_weight_outlined,
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
              l10n.addFirstMeasurement,
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

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({
    required this.measurement,
    required this.l10n,
  });

  final BmiMeasurement measurement;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return Card(
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
                Icons.monitor_weight,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KMI: ${measurement.bmiValue}',
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${measurement.heightCm} ${l10n.cmUnit} / '
                    '${measurement.weightKg} ${l10n.kgUnit}',
                    style: context.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Text(
                    '${dateFormat.format(measurement.measuredAt)} '
                    '${timeFormat.format(measurement.measuredAt)}',
                    style: context.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
