import 'package:flutter/material.dart';

import 'package:avis_package/src/core/theme/app_colors_extension.dart';
import 'package:avis_package/src/core/utils/constants/app_colors.dart';

class AppTheme {
  /// Getters (not [static final]) so theme colors update on hot reload / rebuild.
  static ThemeData get light => _baseTheme(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBrand,
      secondary: AppColors.primaryBrand,
      surface: AppColors.white,
      error: AppColors.red,
      secondaryContainer: Color(0xFFF1F1F1),
    ),
    extensions: [
      const AppColorsExtension(
        // Text
        primaryText: AppColors.black,
        secondaryText: AppColors.grey500, // Or grey600 based on preference
        tertiaryText: AppColors.black200,
        inverseText: AppColors.white,

        // Backgrounds
        background: AppColors.white,
        surface: AppColors.white,
        surfaceDim: AppColors.greyLight500,
        cardBackground: AppColors.white,
        dialogBackground: AppColors.white,
        modalBackground: AppColors.white,
        secondaryContainer: Color(0xFFF1F1F1),
        outline: AppColors.greyLight200,

        // Inputs
        inputBackground: AppColors.white,
        inputBorder: AppColors.greyLight300,
        inputFocusedBorder: AppColors.primaryBrand,
        inputErrorBorder: AppColors.error100,

        // Status
        success: AppColors.green,
        successBackground: AppColors.lightGreen,
        warning: AppColors.orange,
        warningBackground: AppColors.orangeLight, // Need to verify if exists
        error: AppColors.error100,
        errorBackground: AppColors.errorLight,
        info: AppColors.grey600, // Placeholder
        infoBackground: AppColors.grey100,

        // Brand/Action
        primary: AppColors.primaryBrand,
        secondary: AppColors.primaryBrand,
        actionPillBackground: AppColors.lightGreenPill,

        // Borders
        border: AppColors.greyLight300,
        divider: AppColors.grey200,
      ),
    ],
  );

  static ThemeData get dark => _baseTheme(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBrand,
      secondary: AppColors.primaryBrand,
      surface: Color(0xFF1E1E1E), // Dark grey surface
      error: AppColors.red,
      secondaryContainer: Color(0xFF121212),
    ),
    extensions: [
      const AppColorsExtension(
        // Text
        primaryText: AppColors.white,
        secondaryText: AppColors.grey300,
        tertiaryText: AppColors.black200,
        inverseText: AppColors.black,

        // Backgrounds
        background: Color(0xFF121212), // Material Dark Background
        surface: Color(0xFF1E1E1E),
        surfaceDim: Color(0xFF121212),
        cardBackground: Color(0xFF1E1E1E),
        dialogBackground: Color(0xFF2C2C2C),
        modalBackground: Color(0xFF2C2C2C),
        secondaryContainer: Color(0xFF121212),
        outline: Color(0xFF2C2C2C),

        // Inputs
        inputBackground: Color(0xFF2C2C2C),
        inputBorder: Color(0xFF444444),
        inputFocusedBorder: AppColors.primaryBrand,
        inputErrorBorder: AppColors.errorLight,

        // Status
        success: AppColors.green,
        successBackground: Color(0xFF1B3E2D), // Darkened Green bg
        warning: AppColors.orange,
        warningBackground: Color(0xFF4A3423), // Darkened Orange bg
        error: AppColors.error100,
        errorBackground: Color(0xFF4A1818), // Darkened Error bg
        info: AppColors.grey300,
        infoBackground: Color(0xFF2C2C2C),

        // Brand/Action
        primary:
            AppColors.primaryBrand, // Might need adjustment for dark mode contrast
        secondary: AppColors.primaryBrand,
        actionPillBackground: Color.fromARGB(255, 38, 84, 62),

        // Borders
        border: Color(0xFF444444),
        divider: Color(0xFF444444),
      ),
    ],
  );

  static ThemeData _baseTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required List<ThemeExtension<dynamic>> extensions,
  }) {
    // Helper to access colors for main ThemeData properties
    // We cast to AppColorsExtension to get semantic values
    final api =
        extensions.firstWhere((e) => e is AppColorsExtension)
            as AppColorsExtension;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: api.primary,
      colorScheme: colorScheme.copyWith(
        primary: api.primary,
        onPrimary: AppColors.white,
        secondary: api.secondary,
        onSecondary: AppColors.white,
        surface: api.surface,
        error: api.error,
        secondaryContainer: api.secondaryContainer,
        outline: api.outline,
      ),
      extensions: extensions,
      scaffoldBackgroundColor: api.background,
      appBarTheme: AppBarTheme(
        toolbarHeight: kToolbarHeight,
        backgroundColor: api.background,
        elevation: 0,
        iconTheme: IconThemeData(color: api.primaryText),
        titleTextStyle: TextStyle(
          color: api.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: api.divider,
      cardColor: api.cardBackground,
      dialogTheme: DialogThemeData(backgroundColor: api.dialogBackground),
    );
  }
}
