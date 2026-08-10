import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/generated/locale_keys.g.dart';

/// Blocks [child] when no customer id is stored (user must sign in via host app).
class LoginRequiredGate extends StatelessWidget {
  const LoginRequiredGate({super.key, required this.child});

  final Widget child;

  static bool get isLoggedIn => sl<AuthLocalService>().getCustomerId() != null;

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) return child;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 56,
                  color: context.colors.tertiaryText,
                ),
                const SizedBox(height: 20),
                TextWidget(
                  LocaleKeys.common_user_not_logged_in.tr(),
                  style: AppTextStyles.bodyLargeBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
