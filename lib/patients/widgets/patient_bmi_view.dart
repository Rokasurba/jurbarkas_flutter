import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patient_health_data_cubit.dart';
import 'package:frontend/patients/widgets/patient_no_data_view.dart';

/// Read-only BMI view for doctors/admins.
class PatientBmiView extends StatelessWidget {
  const PatientBmiView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientHealthDataCubit, PatientHealthDataState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (_, bmi, __) => bmi.isEmpty
              ? PatientNoDataView(
                  icon: Icons.accessibility_new_outlined,
                  message: context.l10n.noBmiData,
                )
              : _BmiList(measurements: bmi),
          failure: (message) => PatientNoDataView(
            icon: Icons.error_outline,
            message: message,
          ),
        );
      },
    );
  }
}

class _BmiList extends StatelessWidget {
  const _BmiList({required this.measurements});

  final List<BmiMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: measurements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final measurement = measurements[index];
        return _BmiCard(measurement: measurement, l10n: l10n);
      },
    );
  }
}

class _BmiCard extends StatelessWidget {
  const _BmiCard({
    required this.measurement,
    required this.l10n,
  });

  final BmiMeasurement measurement;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
                Icons.accessibility_new,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.bmiLabel}: ${measurement.bmiValue.toStringAsFixed(1)}',
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${measurement.heightCm} ${l10n.cmUnit} / '
                    '${measurement.weightKg.toStringAsFixed(1)} ${l10n.kgUnit}',
                    style: context.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${measurement.measuredAt.toDateString()} '
                    '${measurement.measuredAt.toTimeString()}',
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
