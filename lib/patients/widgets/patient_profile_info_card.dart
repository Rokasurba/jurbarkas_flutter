import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/data/models/patient_profile.dart';
import 'package:intl/intl.dart';

/// Patient profile info card displaying avatar, name, birth date, and phone.
/// Styled to match the patient card design with F4F4F4 background and 22px radius.
class PatientProfileInfoCard extends StatelessWidget {
  const PatientProfileInfoCard({
    required this.profile,
    super.key,
  });

  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with initials
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.secondaryLight,
              child: Text(
                profile.initials,
                style: context.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.birthDateLabel} ${profile.dateOfBirth != null ? dateFormat.format(profile.dateOfBirth!) : l10n.notSpecified}',
                    style: context.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.phoneNumberLabel} ${profile.phone ?? l10n.notSpecified}',
                    style: context.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.emailLabel} ${profile.email}',
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
