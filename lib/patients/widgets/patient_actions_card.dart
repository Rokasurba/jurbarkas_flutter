import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/l10n/l10n.dart';

/// Card widget with navigation actions for the patient profile page.
/// Contains rows for health data, statistics, and messages.
class PatientActionsCard extends StatelessWidget {
  const PatientActionsCard({
    required this.onHealthDataTap,
    required this.onStatisticsTap,
    required this.onMessagesTap,
    super.key,
  });

  final VoidCallback onHealthDataTap;
  final VoidCallback onStatisticsTap;
  final VoidCallback onMessagesTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.secondaryLight),
      ),
      child: Column(
        children: [
          // Health data
          _ActionRow(
            icon: Icons.favorite_outline,
            label: context.l10n.healthData,
            onTap: onHealthDataTap,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Statistics
          _ActionRow(
            icon: Icons.bar_chart_outlined,
            label: context.l10n.statistics,
            onTap: onStatisticsTap,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Messages
          _ActionRow(
            icon: Icons.message_outlined,
            label: context.l10n.messagesLabel,
            onTap: onMessagesTap,
          ),
        ],
      ),
    );
  }
}

/// Single action row with icon, label, and chevron.
/// Minimum 44dp height for accessibility.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: context.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
