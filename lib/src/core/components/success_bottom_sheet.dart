import 'package:avis_package/src/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class SuccessBottomSheet extends StatelessWidget {
  const SuccessBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => const SuccessBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(43.5, 12, 43.5, 24),
      child: Column(
        children: [
          const Center(child: BottomSheetHandle()),
          const SizedBox(height: 60),
          const SvgIconWidget(name: 'success_check', width: 228, height: 228),
          const SizedBox(height: 24),
          TextWidget(
            LocaleKeys.common_review_submitted.tr(),
            style: AppTextStyles.h1.copyWith(color: context.colors.primaryText),
          ),
          const SizedBox(height: 60),
          AppButton.secondary(
            text: LocaleKeys.common_done.tr(),
            onPressed: () {
              AvisNavigation.pushReplacement(
                context,
                AppRoutes.navigatorHandler,
              );
            },
          ),
        ],
      ),
    );
  }
}
