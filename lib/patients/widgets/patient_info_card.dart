import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/data/models/patient_profile.dart';
import 'package:intl/intl.dart';

/// Card widget displaying patient information with icon + label + value rows.
/// Shows phone, date of birth, patient code, and registration date.
class PatientInfoCard extends StatelessWidget {
  const PatientInfoCard({
    required this.profile,
    super.key,
  });

  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.secondaryLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Phone
            _InfoRow(
              icon: Icons.phone_outlined,
              label: context.l10n.phone,
              value: profile.phone ?? context.l10n.notSpecified,
            ),
            const Divider(height: 24),
            // Date of birth
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: context.l10n.dateOfBirth,
              value: profile.dateOfBirth != null
                  ? dateFormat.format(profile.dateOfBirth!)
                  : context.l10n.notSpecified,
            ),
            const Divider(height: 24),
            // Patient code
            _InfoRow(
              icon: Icons.badge_outlined,
              label: context.l10n.patientCode,
              value: profile.patientCode ?? context.l10n.notSpecified,
            ),
            const Divider(height: 24),
            // Registration date
            _InfoRow(
              icon: Icons.access_time_outlined,
              label: context.l10n.registrationDate,
              value: dateFormat.format(profile.createdAt),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single row in the info card with icon, label, and value.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.secondaryText,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.labelSmall?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
