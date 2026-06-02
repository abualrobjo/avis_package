import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart';

class SuccessWidget extends StatelessWidget {
  const SuccessWidget({
    super.key,
    required this.title,
    required this.description,
    required this.buttonTitle,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String buttonTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 100),
          const SvgIconWidget(name: 'success_check', width: 228, height: 228),
          AppSpaces.large.verticalSpace,
          TextWidget(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(color: context.colors.inverseText),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 49),
            child: TextWidget(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: AppColors.black200,
              ),
            ),
          ),
          const SizedBox(height: 42),
          AppButton.primary(onPressed: onPressed, text: buttonTitle),
        ],
      ),
    );
  }
}
