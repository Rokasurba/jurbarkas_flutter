import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/l10n/l10n.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    required this.onConfirm,
    required this.isLoading,
    super.key,
  });

  final VoidCallback onConfirm;
  final bool isLoading;

  static Future<bool?> show( 
    BuildContext context, {
    required VoidCallback onConfirm,
    bool isLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) => DeleteConfirmationDialog(
        onConfirm: onConfirm,
        isLoading: isLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      title: Text(l10n.deleteConfirmTitle),
      content: Text(l10n.deleteConfirmMessage),
      actions: [
        AppButton.text(
          label: l10n.cancelButton,
          onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
          size: AppButtonSize.small,
        ),
        AppButton.danger(
          label: l10n.deleteButton,
          onPressed: isLoading ? null : onConfirm,
          isLoading: isLoading,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
