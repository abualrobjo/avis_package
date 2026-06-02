import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class CheckBoxWidget extends StatelessWidget {
  const CheckBoxWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool? value;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: const CheckboxThemeData(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      child: Transform.scale(
        scale: 0.75,
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: context.colors.primary,
          checkColor: context.colors.inverseText,
          side: BorderSide(color: context.colors.border, width: 1),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
      ),
    );
  }
}
