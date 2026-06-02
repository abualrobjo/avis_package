import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/generated/locale_keys.g.dart';

/// Generic success dialog with icon, title and Done button.
/// Use [SuccessDialog.show] then [onDone] for post-close callback.
class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.title,
    this.onDone,
  });

  final String title;
  final VoidCallback? onDone;

  static Future<void> show(
    BuildContext context, {
    required String title,
    VoidCallback? onDone,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(title: title, onDone: onDone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.dialogBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppCornerRadius.medium),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SuccessIcon(),
            SizedBox(height: 24.w),
            TextWidget(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLargeBold.copyWith(
                color: context.colors.primaryText,
              ),
            ),
            SizedBox(height: 28.w),
            AppButton.secondary(
              onPressed: () {
                Navigator.of(context).pop();
                onDone?.call();
              },
              text: LocaleKeys.common_done.tr(),
              width: double.infinity,
              height: 48.w,
              padding: EdgeInsets.symmetric(vertical: 14.w),
              customBorderColor: context.colors.border,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 228.w,
      height: 228.w,
      child: Center(
        child: SvgIconWidget(name: 'success', width: 228.w, height: 228.w),
      ),
    );
  }
}
