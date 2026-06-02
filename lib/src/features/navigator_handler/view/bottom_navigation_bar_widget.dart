import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/generated/locale_keys.g.dart';
import 'package:avis_package/src/core/_core.dart' show AppContextExtension, SvgIconWidget, TextWidget;
import 'package:avis_package/src/features/_features.dart' show NavigatorHandlerProvider;

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 69,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.colors.border, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            item(
              iconName: 'Home',
              iconTitle: LocaleKeys.nav_home.tr(),
              selectedIndex: 1,
              context: context,
            ),
            item(
              iconName: 'rides',
              iconTitle: LocaleKeys.nav_my_trip.tr(),
              selectedIndex: 2,
              context: context,
            ),
            item(
              iconName: 'chat',
              iconTitle: LocaleKeys.nav_chat.tr(),
              selectedIndex: 3,
              context: context,
            ),
            item(
              iconName: 'account',
              iconTitle: LocaleKeys.nav_account.tr(),
              selectedIndex: 4,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget item({
    required String iconName,
    required String iconTitle,
    required selectedIndex,
    required BuildContext context,
  }) {
    final provider = Provider.of<NavigatorHandlerProvider>(
      context,
      listen: true,
    );

    return MaterialButton(
      onPressed: () {
        provider.changeSelectedIndexValue(selectedIndex);
      },
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIconWidget(
            name: iconName,
            width: 24,
            height: 24,
            color: selectedIndex == provider.selectedIndex
                ? context.colors.primary
                : context.colors.tertiaryText,
          ),
          const SizedBox(height: 6),
          TextWidget(
            iconTitle,
            style: TextStyle(
              fontSize: 10,
              color: selectedIndex == provider.selectedIndex
                  ? context.colors.primary
                  : context.colors.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }
}
