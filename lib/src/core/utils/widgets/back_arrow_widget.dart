import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart' show AppContextExtension;

class BackArrowWidget extends StatelessWidget {
  const BackArrowWidget({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      margin: const EdgeInsetsDirectional.only(start: 10),
      decoration: BoxDecoration(
        color: context.colors.background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3.5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back_ios_new, size: 20),
      ),
    );
  }
}
