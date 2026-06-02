import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart' show AppContextExtension;

class HorizontalDivider extends StatelessWidget {
  const HorizontalDivider({super.key, this.padding, this.thickness});
  final EdgeInsetsGeometry? padding;
  final double? thickness;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: context.colors.border, thickness: thickness ?? 2, height: 1),
    );
  }
}
