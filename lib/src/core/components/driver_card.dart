import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/_features.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({super.key, required this.data});

  final CustomerTripByIdModel? data;

  Future<void> _onCall(BuildContext context) async {
    final phone = data?.chauffeurPhoneNumber?.trim() ?? '';
    final path = phone.isNotEmpty ? phone : '';
    final uri = Uri(scheme: 'tel', path: path);
    try {
      debugPrint('--->> $phone');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _onChat(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: ChatPageArgs(
        tripId: '${data?.tripId}',
        contactDisplayName: data?.chauffeurNameLocalized(context) ?? '',
        driverDisplayName: data?.chauffeurNameLocalized(context) ?? '',
        contactPhone: data?.chauffeurPhoneNumber?.trim() ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();
    final driverName = data?.chauffeurNameLocalized(context) ?? '';

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: context.colors.border,
              child: (data?.chauffeurPhoto != null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppCornerRadius.absolute,
                      ),
                      child: NetworkImageWidget(url: data!.chauffeurPhoto!),
                    )
                  : TextWidget(
                      driverName.isNotEmpty ? driverName[0].toUpperCase() : '?',
                      style: AppTextStyles.bodyLargeBold.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
            ),
            Positioned(
              left: 4,
              bottom: -7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(AppCornerRadius.absolute),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: AppSpaces.medium,
                      color: AppColors.orange500,
                    ),
                    const SizedBox(width: 2),
                    TextWidget(
                      data?.driverAVGRate?.toStringAsFixed(1) ?? '',
                      style: AppTextStyles.bodyXSmallBold.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                driverName,
                style: AppTextStyles.bodyLargeBold.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
              // TextWidget(
              //   tripInfo?.driverInfo ?? '',
              //   style: AppTextStyles.bodySmall.copyWith(
              //     color: context.colors.secondaryText,
              //   ),
              // ),
            ],
          ),
        ),
        _CircleIconButton(
          onTap: () => _onCall(context),
          iconWidget: SvgIconWidget(
            name: 'phone',
            width: 22,
            height: 22,
            color: context.colors.primaryText,
          ),
        ),
        const SizedBox(width: 12),
        _CircleIconButton(
          onTap: () => _onChat(context),
          badgeCount: 2,
          iconWidget: SvgIconWidget(
            name: 'chat',
            width: 22,
            height: 22,
            color: context.colors.primaryText,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.onTap,
    this.badgeCount,
    this.iconWidget,
  });

  final VoidCallback onTap;
  final int? badgeCount;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.secondaryContainer,
              border: Border.all(color: context.colors.border),
            ),
            child: Center(child: iconWidget),
          ),
        ),
        if (badgeCount != null && badgeCount! > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: TextWidget(
                '$badgeCount',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
