import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// Empty state view shown when no health data is available.
class PatientNoDataView extends StatelessWidget {
  const PatientNoDataView({
    required this.icon,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
