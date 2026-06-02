import 'package:flutter/material.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    // Text
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    required this.inverseText,

    // Backgrounds
    required this.background,
    required this.surface,
    required this.surfaceDim,
    required this.cardBackground,
    required this.dialogBackground,
    required this.modalBackground,
    required this.secondaryContainer,
    required this.outline,

    // Inputs
    required this.inputBackground,
    required this.inputBorder,
    required this.inputFocusedBorder,
    required this.inputErrorBorder,

    // Status
    required this.success,
    required this.successBackground,
    required this.warning,
    required this.warningBackground,
    required this.error,
    required this.errorBackground,
    required this.info,
    required this.infoBackground,

    // Brand/Action
    required this.primary,
    required this.secondary,
    required this.actionPillBackground,

    // Borders/Dividers
    required this.border,
    required this.divider,
  });

  // Text
  final Color primaryText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color inverseText;

  // Backgrounds
  final Color background;
  final Color surface;
  final Color surfaceDim;
  final Color cardBackground;
  final Color dialogBackground;
  final Color modalBackground;
  final Color secondaryContainer;
  final Color outline;

  // Inputs
  final Color inputBackground;
  final Color inputBorder;
  final Color inputFocusedBorder;
  final Color inputErrorBorder;

  // Status
  final Color success;
  final Color successBackground;
  final Color warning;
  final Color warningBackground;
  final Color error;
  final Color errorBackground;
  final Color info;
  final Color infoBackground;

  // Brand/Action
  final Color primary;
  final Color secondary;
  final Color actionPillBackground;

  // Borders/Dividers
  final Color border;
  final Color divider;

  @override
  AppColorsExtension copyWith({
    Color? primaryText,
    Color? secondaryText,
    Color? tertiaryText,
    Color? inverseText,
    Color? background,
    Color? surface,
    Color? surfaceDim,
    Color? secondaryContainer,
    Color? outline,
    Color? cardBackground,
    Color? dialogBackground,
    Color? modalBackground,
    Color? inputBackground,
    Color? inputBorder,
    Color? inputFocusedBorder,
    Color? inputErrorBorder,
    Color? success,
    Color? successBackground,
    Color? warning,
    Color? warningBackground,
    Color? error,
    Color? errorBackground,
    Color? info,
    Color? infoBackground,
    Color? primary,
    Color? secondary,
    Color? actionPillBackground,
    Color? border,
    Color? divider,
  }) {
    return AppColorsExtension(
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      tertiaryText: tertiaryText ?? this.tertiaryText,
      inverseText: inverseText ?? this.inverseText,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      outline: outline ?? this.outline,
      cardBackground: cardBackground ?? this.cardBackground,
      dialogBackground: dialogBackground ?? this.dialogBackground,
      modalBackground: modalBackground ?? this.modalBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocusedBorder: inputFocusedBorder ?? this.inputFocusedBorder,
      inputErrorBorder: inputErrorBorder ?? this.inputErrorBorder,
      success: success ?? this.success,
      successBackground: successBackground ?? this.successBackground,
      warning: warning ?? this.warning,
      warningBackground: warningBackground ?? this.warningBackground,
      error: error ?? this.error,
      errorBackground: errorBackground ?? this.errorBackground,
      info: info ?? this.info,
      infoBackground: infoBackground ?? this.infoBackground,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      actionPillBackground: actionPillBackground ?? this.actionPillBackground,
      border: border ?? this.border,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      tertiaryText: Color.lerp(tertiaryText, other.tertiaryText, t)!,
      inverseText: Color.lerp(inverseText, other.inverseText, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      outline: Color.lerp(outline, other.outline, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      dialogBackground: Color.lerp(
        dialogBackground,
        other.dialogBackground,
        t,
      )!,
      modalBackground: Color.lerp(modalBackground, other.modalBackground, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputFocusedBorder: Color.lerp(
        inputFocusedBorder,
        other.inputFocusedBorder,
        t,
      )!,
      inputErrorBorder: Color.lerp(
        inputErrorBorder,
        other.inputErrorBorder,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      successBackground: Color.lerp(
        successBackground,
        other.successBackground,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBackground: Color.lerp(
        warningBackground,
        other.warningBackground,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      actionPillBackground: Color.lerp(
        actionPillBackground,
        other.actionPillBackground,
        t,
      )!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
