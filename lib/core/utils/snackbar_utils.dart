import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Utility class for showing consistent snackbars across the app.
class AppSnackbar {
  AppSnackbar._();

  // Track last shown message to prevent duplicates
  static String? _lastMessage;
  static DateTime? _lastShownTime;

  /// Shows a success snackbar with soft green background.
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  /// Shows an error snackbar with red background.
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
    );
  }

  /// Shows an info snackbar with blue background.
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.secondary,
      icon: Icons.info_outline,
    );
  }

  /// Shows a warning snackbar with orange background.
  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_amber_outlined,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Prevent showing duplicate snackbars within 500ms
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShownTime != null &&
        now.difference(_lastShownTime!).inMilliseconds < 500) {
      return;
    }

    _lastMessage = message;
    _lastShownTime = now;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

/// Extension on BuildContext for easy snackbar access.
extension SnackbarExtension on BuildContext {
  void showSuccessSnackbar(String message) {
    AppSnackbar.showSuccess(this, message);
  }

  void showErrorSnackbar(String message) {
    AppSnackbar.showError(this, message);
  }

  void showInfoSnackbar(String message) {
    AppSnackbar.showInfo(this, message);
  }

  void showWarningSnackbar(String message) {
    AppSnackbar.showWarning(this, message);
  }
}
