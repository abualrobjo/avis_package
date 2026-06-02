import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        ImageWidget,
        AppContextExtension,
        AppTextStyles,
        SvgIconWidget,
        TextWidget;

class FlexibleSpaceBacgroundWidget extends StatelessWidget {
  final bool isCorporate;
  const FlexibleSpaceBacgroundWidget({super.key, required this.isCorporate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(21, 22, 0, 15),
      child: Column(
        children: [
          const Spacer(),
          Row(
            children: [
              const ImageWidget(name: 'car', width: 159, height: 76),
              const Spacer(flex: 3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Sedan',
                        style: AppTextStyles.bodyLargeBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 12),
                      SvgIconWidget(
                        name: 'profile',
                        color: context.colors.primaryText,
                        width: 16,
                        height: 16,
                      ),
                      TextWidget(
                        '3',
                        style: AppTextStyles.bodyXSmallBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SvgIconWidget(
                        name: 'bag',
                        color: context.colors.primaryText,
                        width: 16,
                        height: 16,
                      ),
                      TextWidget(
                        '2',
                        style: AppTextStyles.bodyXSmallBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                      ),
                    ],
                  ),

                  if (!isCorporate) const SizedBox(height: 10),
                  if (!isCorporate)
                    TextWidget(
                      '\$85.00',
                      style: AppTextStyles.bodyLargeBold.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
