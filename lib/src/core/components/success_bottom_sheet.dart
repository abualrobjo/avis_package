import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/generated/locale_keys.g.dart';

class SuccessBottomSheet extends StatelessWidget {
  const SuccessBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SuccessBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final iconSize = (screenHeight * 0.22).clamp(120.0, 180.0);
    final verticalGap = screenHeight < 700 ? 20.0 : 32.0;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppCornerRadius.large),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: BottomSheetHandle()),
              SizedBox(height: verticalGap),
              SvgIconWidget(
                name: 'success_check',
                width: iconSize,
                height: iconSize,
              ),
              SizedBox(height: verticalGap * 0.75),
              TextWidget(
                avisTr(LocaleKeys.common_review_submitted, context: context),
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(
                  color: context.colors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: verticalGap),
              AppButton.secondary(
                text: avisTr(LocaleKeys.common_done, context: context),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
