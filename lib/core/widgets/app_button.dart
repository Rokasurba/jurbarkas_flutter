import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Button size presets.
enum AppButtonSize {
  small(36),
  medium(44),
  large(56);

  const AppButtonSize(this.height);
  final double height;
}

enum _ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  danger,
  dangerOutlined,
}

/// Unified button widget with named constructors for every visual variant.
///
/// Replaces all raw Flutter buttons across the app with a single,
/// consistent API that handles loading spinners, icons, and sizing.
class AppButton extends StatelessWidget {
  const AppButton._(
    this._variant, {
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.size = AppButtonSize.large,
    super.key,
  });

  /// Primary filled button – main CTA (submit, save, confirm).
  const factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading,
    bool expand,
    AppButtonSize size,
    Key? key,
  }) = _Primary;

  /// Secondary filled button – secondary CTA (AppColors.secondary).
  const factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading,
    bool expand,
    AppButtonSize size,
    Key? key,
  }) = _Secondary;

  /// Outlined button – secondary actions (previous, clear).
  const factory AppButton.outlined({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading,
    bool expand,
    AppButtonSize size,
    Key? key,
  }) = _Outlined;

  /// Text button – tertiary / links (cancel, forgot password).
  const factory AppButton.text({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading,
    bool expand,
    AppButtonSize size,
    Key? key,
  }) = _Text;

  /// Danger filled button – destructive action (delete confirm).
  const factory AppButton.danger({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading,
    bool expand,
    AppButtonSize size,
    Key? key,
  }) = _Danger;

  /// Danger outlined button – destructive outlined (deactivate, logout).
  const factory AppButton.dangerOutlined({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading,
    bool expand,
    AppButtonSize size,
    Key? key,
  }) = _DangerOutlined;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final AppButtonSize size;
  final _ButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    final child = isLoading
        ? SizedBox(
            width: size == AppButtonSize.small ? 16 : 20,
            height: size == AppButtonSize.small ? 16 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _spinnerColor,
            ),
          )
        : _buildLabel(context);

    final button = switch (_variant) {
      _ButtonVariant.primary => FilledButton(
          onPressed: effectiveOnPressed,
          style: _style(context),
          child: child,
        ),
      _ButtonVariant.secondary => FilledButton(
          onPressed: effectiveOnPressed,
          style: _style(context),
          child: child,
        ),
      _ButtonVariant.outlined => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: _style(context),
          child: child,
        ),
      _ButtonVariant.text => TextButton(
          onPressed: effectiveOnPressed,
          style: _style(context),
          child: child,
        ),
      _ButtonVariant.danger => FilledButton(
          onPressed: effectiveOnPressed,
          style: _style(context),
          child: child,
        ),
      _ButtonVariant.dangerOutlined => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: _style(context),
          child: child,
        ),
    };

    if (expand) {
      return SizedBox(
        width: double.infinity,
        height: size.height,
        child: button,
      );
    }

    return SizedBox(height: size.height, child: button);
  }

  Widget _buildLabel(BuildContext context) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size == AppButtonSize.small ? 16 : 20),
          const SizedBox(width: 8),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      );
    }
    return Text(label);
  }

  Color get _spinnerColor => switch (_variant) {
        _ButtonVariant.primary ||
        _ButtonVariant.secondary ||
        _ButtonVariant.danger =>
          Colors.white,
        _ButtonVariant.outlined => AppColors.primary,
        _ButtonVariant.text => AppColors.primary,
        _ButtonVariant.dangerOutlined => AppColors.error,
      };

  ButtonStyle _style(BuildContext context) => switch (_variant) {
        _ButtonVariant.primary => FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: _padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: _textStyle,
          ),
        _ButtonVariant.secondary => FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: _padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: _textStyle,
          ),
        _ButtonVariant.outlined => OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: _padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: _textStyle,
          ),
        _ButtonVariant.text => TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: _textStyle,
          ),
        _ButtonVariant.danger => FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            padding: _padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: _textStyle,
          ),
        _ButtonVariant.dangerOutlined => OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: _padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: _textStyle,
          ),
      };

  EdgeInsetsGeometry get _padding => switch (size) {
        AppButtonSize.small =>
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        AppButtonSize.medium =>
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        AppButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      };

  TextStyle get _textStyle => TextStyle(
        fontSize: switch (size) {
          AppButtonSize.small => 13,
          AppButtonSize.medium => 14,
          AppButtonSize.large => 16,
        },
        fontWeight: FontWeight.w600,
      );
}

class _Primary extends AppButton {
  const _Primary({
    required super.label,
    super.onPressed,
    super.icon,
    super.isLoading,
    super.expand = true,
    super.size,
    super.key,
  }) : super._(_ButtonVariant.primary);
}

class _Secondary extends AppButton {
  const _Secondary({
    required super.label,
    super.onPressed,
    super.icon,
    super.isLoading,
    super.expand = true,
    super.size,
    super.key,
  }) : super._(_ButtonVariant.secondary);
}

class _Outlined extends AppButton {
  const _Outlined({
    required super.label,
    super.onPressed,
    super.icon,
    super.isLoading,
    super.expand = false,
    super.size,
    super.key,
  }) : super._(_ButtonVariant.outlined);
}

class _Text extends AppButton {
  const _Text({
    required super.label,
    super.onPressed,
    super.icon,
    super.isLoading,
    super.expand = false,
    super.size,
    super.key,
  }) : super._(_ButtonVariant.text);
}

class _Danger extends AppButton {
  const _Danger({
    required super.label,
    super.onPressed,
    super.icon,
    super.isLoading,
    super.expand = false,
    super.size,
    super.key,
  }) : super._(_ButtonVariant.danger);
}

class _DangerOutlined extends AppButton {
  const _DangerOutlined({
    required super.label,
    super.onPressed,
    super.icon,
    super.isLoading,
    super.expand = true,
    super.size,
    super.key,
  }) : super._(_ButtonVariant.dangerOutlined);
}
