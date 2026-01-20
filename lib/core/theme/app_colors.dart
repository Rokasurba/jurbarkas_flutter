import 'package:flutter/material.dart';

/// App color constants from Figma design.
abstract class AppColors {
  /// Primary color - used for buttons, links, accents.
  /// Figma: #2B308B
  static const Color primary = Color(0xFF2B308B);

  /// Secondary color - used for headers, highlights.
  /// Figma: #5A81FA
  static const Color secondary = Color(0xFF5A81FA);

  /// Secondary light color - used for light backgrounds, cards.
  /// Figma: #CEDEFF
  static const Color secondaryLight = Color(0xFFCEDEFF);

  /// Secondary text color - used for hints, labels.
  /// Figma: #474A52
  static const Color secondaryText = Color(0xFF474A52);

  /// Main text color - used for primary text content.
  /// Figma: #23252B
  static const Color mainText = Color(0xFF23252B);

  /// Background color - app background.
  /// Figma: #FAFAFE
  static const Color background = Color(0xFFFAFAFE);

  /// Input field fill color.
  /// Figma: #F4F4F4
  static const Color inputFill = Color(0xFFF4F4F4);

  /// Error color - used for destructive actions and errors.
  static const Color error = Color(0xFFDC3545);
}
