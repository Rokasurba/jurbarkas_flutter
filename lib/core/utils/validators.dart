import 'package:flutter/widgets.dart';
import 'package:frontend/l10n/l10n.dart';

/// Common form validators.
class AppValidators {
  AppValidators._();

  /// Validates that a field is not empty.
  static FormFieldValidator<String> required(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validates email format.
  static FormFieldValidator<String> email(BuildContext context) {
    return (value) {
      final l10n = context.l10n;
      if (value == null || value.isEmpty) {
        return l10n.emailRequired;
      }
      if (!_emailRegex.hasMatch(value)) {
        return l10n.emailInvalid;
      }
      return null;
    };
  }

  /// Validates password with minimum length.
  static FormFieldValidator<String> password(
    BuildContext context, {
    int minLength = 8,
  }) {
    return (value) {
      final l10n = context.l10n;
      if (value == null || value.isEmpty) {
        return l10n.passwordRequired;
      }
      if (value.length < minLength) {
        return l10n.passwordMinLength;
      }
      return null;
    };
  }

  /// Validates that password confirmation matches.
  static FormFieldValidator<String> confirmPassword(
    BuildContext context,
    TextEditingController passwordController,
  ) {
    return (value) {
      final l10n = context.l10n;
      if (value == null || value.isEmpty) {
        return l10n.confirmPasswordRequired;
      }
      if (value != passwordController.text) {
        return l10n.passwordsDoNotMatch;
      }
      return null;
    };
  }

  /// Validates minimum length.
  static FormFieldValidator<String> minLength(
    int length,
    String errorMessage,
  ) {
    return (value) {
      if (value != null && value.length < length) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validates maximum length.
  static FormFieldValidator<String> maxLength(
    int length,
    String errorMessage,
  ) {
    return (value) {
      if (value != null && value.length > length) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Combines multiple validators.
  static FormFieldValidator<String> combine(
    List<FormFieldValidator<String>> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
}
