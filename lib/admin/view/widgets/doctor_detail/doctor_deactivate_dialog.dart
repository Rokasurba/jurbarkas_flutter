import 'package:flutter/material.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/l10n/l10n.dart';

class DoctorDeactivateDialog extends StatelessWidget {
  const DoctorDeactivateDialog({required this.doctor, super.key});

  final User doctor;

  static Future<bool> show(BuildContext context, {required User doctor}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DoctorDeactivateDialog(doctor: doctor),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.arTikraiDeaktyvuoti),
      content: Text('${doctor.fullName} (${doctor.email})'),
      actions: [
        AppButton.text(
          label: l10n.cancelButton,
          onPressed: () => Navigator.of(context).pop(false),
          size: AppButtonSize.small,
        ),
        AppButton.danger(
          label: l10n.confirmButton,
          onPressed: () => Navigator.of(context).pop(true),
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
