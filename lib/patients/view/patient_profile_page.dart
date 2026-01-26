import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patient_health_data_cubit.dart';
import 'package:frontend/patients/cubit/patient_profile_cubit.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/patients/widgets/health_indicator_card.dart';
import 'package:frontend/patients/widgets/patient_profile_info_card.dart';

/// Patient profile page displaying patient info and health indicators.
/// Allows navigation to detailed health data views.
@RoutePage()
class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({
    @PathParam('id') required this.patientId,
    super.key,
  });

  final int patientId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = PatientProfileCubit(
              patientsRepository: context.read<PatientsRepository>(),
              patientId: patientId,
            );
            unawaited(cubit.loadProfile());
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = PatientHealthDataCubit(
              patientsRepository: context.read<PatientsRepository>(),
              patientId: patientId,
            );
            unawaited(cubit.loadHealthData());
            return cubit;
          },
        ),
      ],
      child: const _PatientProfileView(),
    );
  }
}

class _PatientProfileView extends StatelessWidget {
  const _PatientProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          l10n.dashboardTitle,
          style: context.appBarTitle.copyWith(color: Colors.white),
        ),
      ),
      body: BlocBuilder<PatientProfileCubit, PatientProfileState>(
        builder: (context, profileState) {
          return profileState.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loaded: (profile) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Patient info card
                  PatientProfileInfoCard(profile: profile),
                  const SizedBox(height: 24),
                  // Section header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.mainIndicators,
                          style: context.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.notChecked,
                          style: context.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Health indicators
                  BlocBuilder<PatientHealthDataCubit, PatientHealthDataState>(
                    builder: (context, healthState) {
                      return healthState.when(
                        initial: () => const SizedBox.shrink(),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        loaded: (bloodPressure, bmi, bloodSugar) {
                          // Get latest values
                          final latestBp = bloodPressure.isNotEmpty
                              ? bloodPressure.first
                              : null;
                          final latestBmi = bmi.isNotEmpty ? bmi.first : null;
                          final latestSugar = bloodSugar.isNotEmpty
                              ? bloodSugar.first
                              : null;

                          return Column(
                            children: [
                              // Blood pressure
                              HealthIndicatorCard(
                                title: l10n.bloodPressureTitle,
                                value: latestBp != null
                                    ? '${latestBp.systolic}/${latestBp.diastolic}'
                                    : '00/00',
                                unit: l10n.mmHgUnit,
                                icon: Icons.water_drop_outlined,
                                onTap: () => _onBloodPressureTap(context),
                              ),
                              // Blood sugar
                              HealthIndicatorCard(
                                title: l10n.bloodSugarTitle,
                                value: latestSugar != null
                                    ? latestSugar.glucoseLevel
                                        .toStringAsFixed(1)
                                    : '00',
                                unit: l10n.mmolLUnit,
                                icon: Icons.science_outlined,
                                onTap: () => _onBloodSugarTap(context),
                              ),
                              // BMI
                              HealthIndicatorCard(
                                title: l10n.bmiTitle,
                                value: latestBmi != null
                                    ? latestBmi.bmiValue.toStringAsFixed(1)
                                    : '00',
                                unit: l10n.bmiLabel,
                                icon: Icons.monitor_weight_outlined,
                                onTap: () => _onBmiTap(context),
                              ),
                            ],
                          );
                        },
                        failure: (message) => Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              message,
                              style: context.bodyMedium?.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            failure: (message) => _ErrorView(
              message: message,
              onRetry: () => context.read<PatientProfileCubit>().loadProfile(),
            ),
          );
        },
      ),
    );
  }

  void _onBloodPressureTap(BuildContext context) {
    final state = context.read<PatientProfileCubit>().state;
    final profile = state.profileOrNull;
    if (profile != null) {
      unawaited(
        context.router.push(
          PatientBloodPressureViewRoute(
            patientId: profile.id,
            patientName: profile.fullName,
          ),
        ),
      );
    }
  }

  void _onBloodSugarTap(BuildContext context) {
    final state = context.read<PatientProfileCubit>().state;
    final profile = state.profileOrNull;
    if (profile != null) {
      unawaited(
        context.router.push(
          PatientBloodSugarViewRoute(
            patientId: profile.id,
            patientName: profile.fullName,
          ),
        ),
      );
    }
  }

  void _onBmiTap(BuildContext context) {
    final state = context.read<PatientProfileCubit>().state;
    final profile = state.profileOrNull;
    if (profile != null) {
      unawaited(
        context.router.push(
          PatientBmiViewRoute(
            patientId: profile.id,
            patientName: profile.fullName,
          ),
        ),
      );
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
