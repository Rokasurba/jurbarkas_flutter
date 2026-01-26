import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/l10n/l10n.dart';

/// A reusable status badge widget for displaying active/inactive status.
/// Shows green "Aktyvus" for active and gray "Neaktyvus" for inactive.
/// Includes semantic accessibility labels for screen readers.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.isActive,
    super.key,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final statusText =
        isActive ? context.l10n.statusActive : context.l10n.statusInactive;

    return Semantics(
      label: statusText,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.secondaryText.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          statusText,
          style: context.labelSmall?.copyWith(
            color: isActive ? AppColors.success : AppColors.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
