import 'package:flutter/material.dart';

import 'package:avis_package/src/core/theme/app_colors_extension.dart';

class AppColors {
  ///  BRAND COLORS
  /// Primary CTA (filled buttons, Material primary/secondary, focus rings).
  /// Deep red — distinct from legacy orange accents.
  static const Color primaryBrand = Color(0xFFD4002A);

  static const Color orange = Color(0xFFFF8D28);
  static const Color orange500 = Color(0xFFD4002A);
  static const Color orange300 = Color(0xFFF38D57);
  static const Color orange50 = Color(0xFFFDEEE6);
  static const Color orangeLight = Color(0xFFFEF3E6);
  static const Color orangeLight500 = Color(0xFFF68B00);

  static Color orangeOpacity14 = const Color(
    0xFFD4002A,
  ).withValues(alpha: 0.14);

  static const Color grey900 = Color(0xFF2A2927);
  static const Color grey600 = Color(0xFF5C5855);
  static const Color grey500 = Color(0xFF65615D);
  static const Color grey400 = Color(0xFF84817D);
  static const Color grey300 = Color(0xFF989592);
  static const Color grey200 = Color(0xFFB8B6B4);
  static const Color grey100 = Color(0xFFF6F5F3);
  static const Color grey50 = Color(0xFFA09E9A);
  static const Color greyLight = Color(0xFFE7E5E1);
  static const Color greyLight50 = Color(0xFFFCFCFB);
  static const Color greyLight200 = Color(0xFFF1F0EE);
  static const Color greyLight300 = Color(0xFFEBE9E6);
  static const Color greyLight400 = Color(0xFF84817D);
  static const Color greyLight500 = Color(0xFFE1DED9);
  static const Color greyEF= Color(0xFFEFEFEF);
  static const Color borderColor = Color(0x3365625D);


  static const Color green = Color(0xFF34C759);
  static const Color lightGreen = Color(0xFFF0FFF7);
  static const Color lightGreenPill = Color(0xFFE3FFF0);

  static const Color red = Color(0xFFFF383C);
  static const Color red500 = Color(0xFFD4012A);
  static const Color error100 = Color(0xFFC7002B);
  static const Color errorLight = Color(0xFFFFEBEB);

  static const Color black = Color(0xFF000000);
  static const Color black200 = Color(0xFF8A8A8A);

  static const Color white = Color(0xFFFFFFFF);
  static const Color white600 = Color(0xFFE8E8E8);

  /// Returns the theme's [AppColorsExtension], or a default light one if the host
  /// app does not provide it (e.g. when using the package from another app).
  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>() ??
        _defaultLightExtension;
  }

  static final AppColorsExtension _defaultLightExtension =
      AppColorsExtension(
    primaryText: black,
    secondaryText: grey500,
    tertiaryText: black200,
    inverseText: white,
    background: white,
    surface: white,
    surfaceDim: greyLight500,
    cardBackground: white,
    dialogBackground: white,
    modalBackground: white,
    secondaryContainer: const Color(0xFFF1F1F1),
    outline: greyLight200,
    inputBackground: white,
    inputBorder: greyLight300,
    inputFocusedBorder: primaryBrand,
    inputErrorBorder: error100,
    success: green,
    successBackground: lightGreen,
    warning: orange,
    warningBackground: orangeLight,
    error: error100,
    errorBackground: errorLight,
    info: grey600,
    infoBackground: grey100,
    primary: primaryBrand,
    secondary: primaryBrand,
    actionPillBackground: lightGreenPill,
    border: greyLight300,
    divider: grey200,
  );
}
