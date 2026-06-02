import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avis_package/src/features/_features.dart' show AddNewCardProvider;
import 'package:avis_package/src/core/_core.dart'
    show
        AppContextExtension,
        AppTextStyles,
        SvgIconWidget,
        TextWidget,
        AppSpaces,
        AppCornerRadius,
        AppRoutes;

class TripPaymentWidget extends StatelessWidget {
  const TripPaymentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            'Payment method',
            style: AppTextStyles.h3.copyWith(color: context.colors.primaryText),
          ),
          const SizedBox(height: AppSpaces.large),
          Consumer<AddNewCardProvider>(
            builder: (context, provider, child) {
              final cards = provider.cards;

              return Column(
                children: [
                  ...cards.map((card) {
                    final String last4 =
                        card.number != null && card.number!.length >= 4
                        ? card.number!.substring(card.number!.length - 4)
                        : '';
                    final isSelected = card.isDefault ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpaces.small),
                      child: GestureDetector(
                        onTap: () {
                          if (card.id != null) {
                            provider.setAsDefault(card.id!);
                          }
                        },
                        child: Container(
                          height: 51,
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            left: AppSpaces.onSides,
                            right: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(
                              AppCornerRadius.small,
                            ),
                          ),
                          child: Row(
                            children: [
                              SvgIconWidget(
                                name: 'card',
                                width: 22,
                                height: 22,
                                color: context.colors.tertiaryText,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextWidget(
                                  card.name != null && card.name!.isNotEmpty
                                      ? '${card.name} ****$last4'
                                      : 'Personal Card ****$last4',
                                  style: AppTextStyles.bodyLargeBold.copyWith(
                                    color: context.colors.tertiaryText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: context.colors.tertiaryText,
                                ),
                                onSelected: (value) {
                                  if (card.id == null) return;
                                  if (value == 'default') {
                                    provider.setAsDefault(card.id!);
                                  } else if (value == 'delete') {
                                    provider.deleteCard(card.id!);
                                  }
                                  // Edit can be added later if needed or navigate to specific edit page
                                },
                                itemBuilder: (context) => [
                                  if (!isSelected)
                                    const PopupMenuItem(
                                      value: 'default',
                                      child: Text('Set as default'),
                                    ),
                                  // const PopupMenuItem(
                                  //   value: 'edit',
                                  //   child: Text('Edit card'),
                                  // ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                              Container(
                                width: 21,
                                height: 21,
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? context.colors.primary
                                        : context.colors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.colors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  // "Add new card" option always at the bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpaces.small),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                        context,
                        AppRoutes.addNewCard,
                        arguments: context.read<AddNewCardProvider>(),
                      );
                      },
                      child: Container(
                        height: 51,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpaces.onSides,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.colors.border),
                          borderRadius: BorderRadius.circular(
                            AppCornerRadius.small,
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgIconWidget(
                              name: 'add',
                              width: 22,
                              height: 22,
                              color: context.colors.tertiaryText,
                            ),
                            const SizedBox(width: 8),
                            TextWidget(
                              'Add new card',
                              style: AppTextStyles.bodyLargeBold.copyWith(
                                color: context.colors.tertiaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
