import 'package:flutter/material.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/dashboard/data/models/user_profile.dart';
import 'package:frontend/l10n/l10n.dart';

class PatientProfileCard extends StatelessWidget {
  const PatientProfileCard({
    required this.profile,
    super.key,
  });

  final UserProfile profile;

  String get _initials {
    final namePart = profile.name.isNotEmpty ? profile.name[0] : '';
    final surnamePart = profile.surname.isNotEmpty ? profile.surname[0] : '';
    return '$namePart$surnamePart'.toUpperCase();
  }

  String get _fullName => '${profile.name} ${profile.surname}';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.secondary,
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainText,
                    ),
                  ),
                  if (profile.dateOfBirth != null) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: context.l10n.birthDateLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          TextSpan(
                            text: ' ${profile.dateOfBirth}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (profile.phone != null) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: context.l10n.phoneNumberLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          TextSpan(
                            text: ' ${profile.phone}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
