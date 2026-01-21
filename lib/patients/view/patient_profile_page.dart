import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

/// Stub page for patient profile view.
/// This will be fully implemented in Story 4.3.
@RoutePage()
class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({
    @PathParam('id') required this.patientId,
    super.key,
  });

  final int patientId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          l10n.patientProfileTitle,
          style: context.appBarTitle,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: AppColors.secondaryText.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.patientProfileComingSoon,
                style: context.titleLarge?.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Patient ID: $patientId',
                style: context.bodyMedium?.copyWith(
                  color: AppColors.secondaryText.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
