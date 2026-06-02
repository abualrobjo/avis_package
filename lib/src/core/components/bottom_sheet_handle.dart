import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: 108,
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppCornerRadius.medium),
          bottomRight: Radius.circular(AppCornerRadius.medium),
        ),
      ),
    );
  }
}
