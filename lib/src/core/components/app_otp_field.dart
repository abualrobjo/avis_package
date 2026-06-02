import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import 'package:avis_package/src/core/_core.dart';

class AppOtpField extends StatelessWidget {
  const AppOtpField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.length = 4,
    this.onCompleted,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final int length;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    // Pin theme styling
    final defaultPinTheme = PinTheme(
      width: 53,
      height: 56,
      textStyle: AppTextStyles.h3.copyWith(color: context.colors.primary),
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(AppCornerRadius.medium.r),
        border: Border.all(color: context.colors.inputBorder),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(AppCornerRadius.medium.r),
        border: Border.all(color: context.colors.primary, width: 1),
      ),
    );

    final filledPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(AppCornerRadius.medium.r),
        border: Border.all(color: context.colors.primary),
      ),
    );

    return Pinput(
      length: length,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: filledPinTheme,
      separatorBuilder: (index) => SizedBox(width: length == 4 ? 30.w : 10.w),
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      preFilledWidget: Text(
        '-',
        style: AppTextStyles.h3.copyWith(color: context.colors.tertiaryText),
      ),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
