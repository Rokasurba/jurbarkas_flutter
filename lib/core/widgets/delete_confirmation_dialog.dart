import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
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
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: isLoading ? null : onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.deleteButton),
        ),
      ],
    );
  }
}
