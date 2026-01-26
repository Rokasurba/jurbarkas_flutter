import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patient_health_data_cubit.dart';
import 'package:frontend/patients/widgets/patient_no_data_view.dart';

/// Read-only blood pressure view for doctors/admins.
class PatientBloodPressureView extends StatelessWidget {
  const PatientBloodPressureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientHealthDataCubit, PatientHealthDataState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (bloodPressure, _, __) => bloodPressure.isEmpty
              ? PatientNoDataView(
                  icon: Icons.favorite_outline,
                  message: context.l10n.noBloodPressureData,
                )
              : _BloodPressureList(readings: bloodPressure),
          failure: (message) => PatientNoDataView(
            icon: Icons.error_outline,
            message: message,
          ),
        );
      },
    );
  }
}

class _BloodPressureList extends StatelessWidget {
  const _BloodPressureList({required this.readings});

  final List<BloodPressureReading> readings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: readings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final reading = readings[index];
        return _BloodPressureCard(reading: reading, l10n: l10n);
      },
    );
  }
}

class _BloodPressureCard extends StatelessWidget {
  const _BloodPressureCard({
    required this.reading,
    required this.l10n,
  });

  final BloodPressureReading reading;
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
                Icons.favorite,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${reading.systolic}/${reading.diastolic} ${l10n.mmHgUnit}',
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reading.measuredAt.toDateString()} '
                    '${reading.measuredAt.toTimeString()}',
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
