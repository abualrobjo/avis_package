import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class TextButtonComponent extends StatelessWidget {
  const TextButtonComponent({
    super.key,
    required this.title,
    required this.onPressed,
  });

  final String title;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        overlayColor: Colors.transparent,
      ),
      child: TextWidget(
        title,
        style: AppTextStyles.bodyMediumBold.copyWith(
          color: context.colors.primary,
        ),
      ),
    );
  }
}
