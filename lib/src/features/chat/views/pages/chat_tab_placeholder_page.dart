import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

/// Shown on the bottom-nav chat tab when no trip chat is selected.
class ChatTabPlaceholderPage extends StatelessWidget {
  const ChatTabPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: TextWidget(
          'Chat',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 56,
                color: context.colors.secondaryText,
              ),
              const SizedBox(height: 16),
              TextWidget(
                'No active trip chat',
                style: AppTextStyles.bodyLargeBold.copyWith(
                  color: context.colors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextWidget(
                'Open chat from your active trip or trip details to message your driver.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
