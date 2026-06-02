import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

/// From-field icon: small orange circle inside a larger lighter orange outlined circle.
class FromLocationIcon extends StatelessWidget {
  const FromLocationIcon({super.key, required this.colors});

  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withValues(alpha: 0.15),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
