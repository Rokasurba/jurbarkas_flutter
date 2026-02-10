import 'package:flutter/material.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/widgets/app_button.dart';
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

    if (doctor.isActive) {
      return AppButton.dangerOutlined(
        label: l10n.deactivateButton,
        icon: Icons.person_off_outlined,
        onPressed: isUpdating ? null : onDeactivate,
        isLoading: isUpdating,
      );
    }

    return AppButton.primary(
      label: l10n.activateButton,
      icon: Icons.person_add_outlined,
      onPressed: isUpdating ? null : onReactivate,
      isLoading: isUpdating,
    );
  }
}
