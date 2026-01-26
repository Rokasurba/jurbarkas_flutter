import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/patients/data/models/patient_profile.dart';
import 'package:frontend/patients/widgets/status_badge.dart';

/// Header widget for the patient profile page.
/// Displays avatar with initials, full name, status badge, and patient code.
class PatientProfileHeader extends StatelessWidget {
  const PatientProfileHeader({
    required this.profile,
    super.key,
  });

  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Large avatar with initials (56dp diameter per spec)
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              profile.initials,
              style: context.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Full name
          Text(
            profile.fullName,
            style: context.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Status badge
          StatusBadge(isActive: profile.isActive),
          const SizedBox(height: 8),
          // Patient code
          if (profile.patientCode != null)
            Text(
              profile.patientCode!,
              style: context.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
        ],
      ),
    );
  }
}
