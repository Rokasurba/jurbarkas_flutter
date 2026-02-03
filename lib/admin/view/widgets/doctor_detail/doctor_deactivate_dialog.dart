import 'package:flutter/material.dart';
import 'package:frontend/auth/data/models/user_model.dart';
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.confirmButton),
        ),
      ],
    );
  }
}
