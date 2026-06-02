import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class CounterWidget extends StatelessWidget {
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterWidget({
    super.key,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: 103,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppCornerRadius.xSmall),
        border: Border.all(color: context.colors.border, width: 0.50),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onDecrement,
              child: SizedBox(
                height: 25,
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: count > 0
                      ? context.colors.secondaryText
                      : context.colors.border,
                ),
              ),
            ),
          ),
          const VerticalDivider(color: Colors.transparent, width: 0.50),
          Expanded(
            child: TextWidget(
              count.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmallBold.copyWith(
                color: context.colors.secondaryText,
              ),
            ),
          ),
          const VerticalDivider(color: Colors.transparent, width: 0.50),
          Expanded(
            child: GestureDetector(
              onTap: onIncrement,
              child: SizedBox(
                height: 25,
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: context.colors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
