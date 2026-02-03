import 'package:flutter/material.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/l10n/l10n.dart';

class DoctorActionButtons extends StatelessWidget {
  const DoctorActionButtons({
    required this.doctor,
    required this.isUpdating,
    required this.onDeactivate,
    required this.onReactivate,
    super.key,
  });

  final User doctor;
  final bool isUpdating;
  final VoidCallback onDeactivate;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (doctor.isActive) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: isUpdating ? null : onDeactivate,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
          icon: isUpdating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.person_off_outlined),
          label: Text(l10n.deactivateButton),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isUpdating ? null : onReactivate,
        icon: isUpdating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.person_add_outlined),
        label: Text(l10n.activateButton),
      ),
    );
  }
}
