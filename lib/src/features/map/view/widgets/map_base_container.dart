import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class MapBaseContainer extends StatelessWidget {
  const MapBaseContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(
        AppSpaces.onSides,
      ).copyWith(bottom: AppSpaces.large),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const BottomSheetHandle(),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
