import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({
    required this.patient,
    required this.onTap,
    super.key,
  });

  final PatientListItem patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Avatar with initials
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.secondaryLight,
                  child: Text(
                    patient.initials,
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Name
                Expanded(
                  child: Text(
                    patient.fullName,
                    style: context.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // Arrow icon
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.mainText,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
