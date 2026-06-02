import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class AppCheckboxLabel extends StatelessWidget {
  const AppCheckboxLabel({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.style,
  });

  final String title;
  final bool? value;
  final void Function(bool?)? onChanged;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value!),
      child: Row(
        children: [
          CheckBoxWidget(value: value, onChanged: onChanged),
          TextWidget(
            title,
            style: style ?? AppTextStyles.bodySmall.copyWith(color: AppColors.grey300),
          ),
        ],
      ),
    );
  }
}
