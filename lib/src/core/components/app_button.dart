import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class AppButton extends StatelessWidget {
  const AppButton._({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.prefix,
    this.width,
    this.height,
    this.isLoading = false,
    this.fontSize,
    this.padding,
    this.type,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Widget? prefix;
  final double? width;
  final double? height;
  final bool isLoading;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final AppButtonType? type;

  // 1. Primary Factory
  factory AppButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required String text,
    Color? backgroundColor,
    Color? foregroundColor,
    Widget? prefix,
    double? width,
    double? height,
    bool isLoading = false,
    double? fontSize,
    EdgeInsetsGeometry? padding,
  }) {
    return AppButton._(
      key: key,
      onPressed: onPressed,
      text: text,
      type: AppButtonType.primary,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      prefix: prefix,
      width: width,
      height: height,
      isLoading: isLoading,
      fontSize: fontSize,
      padding: padding,
    );
  }

  // 2. Secondary Factory
  factory AppButton.secondary({
    Key? key,
    required VoidCallback? onPressed,
    required String text,
    Color? backgroundColor,
    Color? foregroundColor,
    Widget? prefix,
    double? width,
    double? height,
    bool isLoading = false,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    Color? customBorderColor,
  }) {
    return AppButton._(
      key: key,
      onPressed: onPressed,
      text: text,
      type: AppButtonType.secondary,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: customBorderColor,
      prefix: prefix,
      width: width,
      height: height,
      isLoading: isLoading,
      fontSize: fontSize,
      padding: padding,
    );
  }

  // 3. Tertiary Factory
  factory AppButton.tertiary({
    Key? key,
    required VoidCallback? onPressed,
    required String text,
    Color? backgroundColor,
    Color? foregroundColor,
    Widget? prefix,
    double? width,
    double? height,
    bool isLoading = false,
    double? fontSize,
    EdgeInsetsGeometry? padding,
  }) {
    return AppButton._(
      key: key,
      onPressed: onPressed,
      text: text,
      type: AppButtonType.tertiary,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      prefix: prefix,
      width: width,
      height: height,
      isLoading: isLoading,
      fontSize: fontSize,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Color resolvedBackgroundColor = backgroundColor ?? Colors.transparent;
    Color resolvedForegroundColor =
        foregroundColor ?? context.colors.inverseText;
    Color? resolvedBorderColor = borderColor;

    switch (type) {
      case AppButtonType.primary:
        resolvedBackgroundColor =
            backgroundColor ?? AppColors.primaryBrand;
        // Same on light/dark: white on brand red (inverseText is black in dark theme).
        resolvedForegroundColor = foregroundColor ?? AppColors.white;
        break;
      case AppButtonType.secondary:
        resolvedBackgroundColor = backgroundColor ?? context.colors.surface;
        resolvedForegroundColor =
            foregroundColor ?? context.colors.secondaryText;
        resolvedBorderColor = borderColor ?? context.colors.border;
        break;
      case AppButtonType.tertiary:
        resolvedBackgroundColor = backgroundColor ?? context.colors.error;
        resolvedForegroundColor = foregroundColor ?? AppColors.white;
        break;
      default:
        resolvedBackgroundColor =
            backgroundColor ?? AppColors.primaryBrand;
        resolvedForegroundColor = foregroundColor ?? AppColors.white;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: resolvedBackgroundColor,
          foregroundColor: resolvedForegroundColor,
          padding:
              padding ??
              const EdgeInsets.symmetric(
                vertical: AppSpaces.medium,
                horizontal: AppSpaces.medium,
              ),
          shape: StadiumBorder(
            side: resolvedBorderColor != null
                ? BorderSide(color: resolvedBorderColor, width: 0.5)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: resolvedForegroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefix != null) ...[
                    prefix!,
                    const SizedBox(width: AppSpaces.small),
                  ],
                  TextWidget(
                    text,
                    style: AppTextStyles.bodyLargeBold.copyWith(
                      color: resolvedForegroundColor,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

enum AppButtonType { primary, secondary, tertiary }
