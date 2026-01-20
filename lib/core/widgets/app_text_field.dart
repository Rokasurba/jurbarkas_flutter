import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/l10n/l10n.dart';

/// Generic reusable text field with customizable properties.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.focusNode,
    this.onFieldSubmitted,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = true,
    this.inputFormatters,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final bool autofocus;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      enabled: enabled,
      autocorrect: autocorrect,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      validator: validator,
    );
  }
}

/// Reusable email text field with built-in validation.
class AppEmailField extends StatelessWidget {
  const AppEmailField({
    required this.controller,
    this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofocus: autofocus,
      enabled: enabled,
      autocorrect: false,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        hintText: l10n.emailLabel,
      ),
      validator: AppValidators.email(context),
    );
  }
}

/// Reusable password text field with visibility toggle.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    required this.controller,
    this.focusNode,
    this.labelText,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? labelText;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool autofocus;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        hintText: widget.labelText ?? l10n.passwordLabel,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      validator: widget.validator ?? AppValidators.password(context),
    );
  }
}

/// Reusable confirm password field that validates against
/// another password controller.
class AppConfirmPasswordField extends StatefulWidget {
  const AppConfirmPasswordField({
    required this.controller,
    required this.passwordController,
    this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final TextEditingController passwordController;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final bool enabled;

  @override
  State<AppConfirmPasswordField> createState() =>
      _AppConfirmPasswordFieldState();
}

class _AppConfirmPasswordFieldState extends State<AppConfirmPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        hintText: l10n.confirmPasswordLabel,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      validator: AppValidators.confirmPassword(
        context,
        widget.passwordController,
      ),
    );
  }
}

/// Reusable OTP input field for single digit.
class AppOtpDigitField extends StatelessWidget {
  const AppOtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        enabled: enabled,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        style: Theme.of(context).textTheme.headlineSmall,
        onChanged: onChanged,
      ),
    );
  }
}
