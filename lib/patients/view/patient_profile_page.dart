import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/admin.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patient_health_data_cubit.dart';
import 'package:frontend/patients/cubit/patient_metric_view_cubit.dart';
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
        BlocProvider(
          create: (context) => AdminPatientDetailCubit(
            adminRepository: AdminRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
      ],
      child: _PatientProfileView(patientId: patientId),
    );
  }
}

class _PatientProfileView extends StatelessWidget {
  const _PatientProfileView({required this.patientId});

  final int patientId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ResponsiveScaffold(
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
                  // Action buttons (doctor/admin only)
                  Builder(
                    builder: (context) {
                      final user =
                          context.read<AuthCubit>().state.user;
                      if (user == null ||
                          (!user.isDoctor && !user.isAdmin)) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Column(
                          children: [
                            // Surveys button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  unawaited(
                                    context.router.push(
                                      PatientSurveysRoute(
                                        patientId: profile.id,
                                        patientName: profile.fullName,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.assignment),
                                label: Text(
                                  l10n.surveyListTitle,
                                  style: context.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Send reminder button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  unawaited(
                                    context.router.push(
                                      SendReminderRoute(
                                        patientId: profile.id,
                                        patientName: profile.fullName,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.notifications_active),
                                label: Text(
                                  l10n.sendReminderButton,
                                  style: context.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            // Admin-only buttons
                            if (user.isAdmin) ...[
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 12),
                              Text(
                                l10n.pacientuValdymas,
                                style: context.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Edit patient button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final result = await context.router.push(
                                      AdminPatientEditRoute(
                                        patientId: patientId,
                                        patient: profile,
                                      ),
                                    );
                                    if (result == true && context.mounted) {
                                      unawaited(
                                        context
                                            .read<PatientProfileCubit>()
                                            .loadProfile(),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: Text(
                                    l10n.redaguotiPacienta,
                                    style: context.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Deactivate/Activate button
                              _AdminPatientStatusButton(
                                patientId: patientId,
                                isActive: profile.isActive,
                              ),
                            ],
                          ],
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
    _navigateToMetric(context, HealthMetricType.bloodPressure);
  }

  void _onBloodSugarTap(BuildContext context) {
    _navigateToMetric(context, HealthMetricType.bloodSugar);
  }

  void _onBmiTap(BuildContext context) {
    _navigateToMetric(context, HealthMetricType.bmi);
  }

  void _navigateToMetric(BuildContext context, HealthMetricType metricType) {
    final state = context.read<PatientProfileCubit>().state;
    final profile = state.profileOrNull;
    if (profile != null) {
      unawaited(
        context.router.push(
          PatientMetricViewRoute(
            patientId: profile.id,
            metricType: metricType,
            patientName: profile.fullName,
          ),
        ),
      );
    }
  }
}

class _AdminPatientStatusButton extends StatelessWidget {
  const _AdminPatientStatusButton({
    required this.patientId,
    required this.isActive,
  });

  final int patientId;
  final bool isActive;

  Future<void> _showDeactivateConfirmation(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deaktyvuotiPacienta),
        content: Text(l10n.arTikraiDeaktyvuotiPacienta),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.deaktyvuotiPacienta),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      unawaited(
        context.read<AdminPatientDetailCubit>().deactivatePatient(patientId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<AdminPatientDetailCubit, AdminPatientDetailState>(
      listener: (context, state) {
        state.whenOrNull(
          deactivated: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pacientasDeaktyvuotas),
                backgroundColor: Colors.orange,
              ),
            );
            unawaited(context.read<PatientProfileCubit>().loadProfile());
          },
          reactivated: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pacientasAktyvuotas),
                backgroundColor: Colors.green,
              ),
            );
            unawaited(context.read<PatientProfileCubit>().loadProfile());
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        );
      },
      child: BlocBuilder<AdminPatientDetailCubit, AdminPatientDetailState>(
        builder: (context, state) {
          final isLoading = state is AdminPatientDetailUpdating;

          if (isActive) {
            // Show deactivate button
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed:
                    isLoading ? null : () => _showDeactivateConfirmation(context),
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.block, color: AppColors.error),
                label: Text(
                  l10n.deaktyvuotiPacienta,
                  style: context.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLoading ? null : AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            );
          } else {
            // Show activate button
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<AdminPatientDetailCubit>()
                        .reactivatePatient(patientId),
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  l10n.aktivuotiPacienta,
                  style: context.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
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
