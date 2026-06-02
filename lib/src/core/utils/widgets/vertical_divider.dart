import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart' show AppSpaces, AppContextExtension;

class VertivalDivider extends StatelessWidget {
  const VertivalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpaces.medium),
      width: 2,
      height: 27,
      color: context.colors.infoBackground,
    );
  }
}
