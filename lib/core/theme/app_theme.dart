import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

export 'app_colors.dart';

/// App-wide theme configuration.
class AppTheme {
  AppTheme._();

  /// Primary app theme.
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    );
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme.copyWith(
        surfaceTint: Colors.transparent,
        surface: AppColors.background,
        primary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
        shadowColor: Colors.black,
        backgroundColor: AppColors.secondary,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        suffixStyle: const TextStyle(color: AppColors.secondary),
        suffixIconColor: AppColors.secondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.background,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.background,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.background,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.background,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.background,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.background,
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: AppColors.background,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.background,
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: AppColors.background,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AppColors.background,
        ),
      ),
      searchBarTheme: const SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(AppColors.background),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.background,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: AppColors.background,
        collapsedBackgroundColor: AppColors.background,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: AppColors.background,
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: AppColors.background,
      ),
    );
  }

  /// Dark theme (future use).
  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// Extension on BuildContext for easy access to theme text styles.
extension AppTextStyles on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Display styles
  TextStyle? get displayLarge => textTheme.displayLarge;
  TextStyle? get displayMedium => textTheme.displayMedium;
  TextStyle? get displaySmall => textTheme.displaySmall;

  /// Headline styles
  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get headlineSmall => textTheme.headlineSmall;

  /// Title styles
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get titleSmall => textTheme.titleSmall;

  /// Body styles
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodySmall => textTheme.bodySmall;

  /// Label styles
  TextStyle? get labelLarge => textTheme.labelLarge;
  TextStyle? get labelMedium => textTheme.labelMedium;
  TextStyle? get labelSmall => textTheme.labelSmall;

  /// Color scheme access
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Color get primaryColor => colorScheme.primary;
  Color get errorColor => colorScheme.error;

  /// Custom app styles
  /// Section header style - size 20, semibold, primary color
  TextStyle get sectionHeader => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  /// App bar title style - size 20, bold
  TextStyle get appBarTitle => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
