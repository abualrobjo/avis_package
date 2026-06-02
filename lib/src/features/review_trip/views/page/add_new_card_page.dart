import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        AppContextExtension,
        AppTextFormFieldComponent,
        AppTextStyles,
        BackArrowWidget,
        TextWidget,
        AppSpaces,
        AppButton,
        CardNumberInputFormatter,
        CardUtils,
        CardType,
        PaymentCard,
        CardMonthInputFormatter,
        ToastNotification,
        successDialog;
import 'package:avis_package/src/features/_features.dart' show AddNewCardProvider;
import 'package:provider/provider.dart';

class AddNewCardPage extends StatefulWidget {
  const AddNewCardPage({super.key});

  @override
  State<AddNewCardPage> createState() => _AddNewCardPageState();
}

class _AddNewCardPageState extends State<AddNewCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  PaymentCard _paymentCard = const PaymentCard();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool _saveForLater = false;

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(_cardNumberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      _paymentCard = _paymentCard.copyWith(type: cardType);
    });
  }

  bool _isAllFieldsFilled() {
    if (_cardNumberController.text.isNotEmpty &&
        _expiryDateController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
      return true;
    }
    return false;
  }

  Future<void> _validateInputs() async {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    } else {
      form.save(); // This ensures all onSaved() methods are called

      log('_paymentCard => $_paymentCard'); // Debugging output

      final cards = context.read<AddNewCardProvider>().cards;
      if (cards.any((element) => element.number == _paymentCard.number)) {
        ToastNotification.showWarningNotification(
          context,
          message: 'Card already exists.',
        );
        return;
      }
      context.read<AddNewCardProvider>().addCard(
        _paymentCard,
        saveForLater: _saveForLater,
      );

      successDialog(
        context,
        message: 'Your new card has been added.',
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    }
  }

  void updatePaymentCard(PaymentCard updatedCard) {
    setState(() {
      _paymentCard = _paymentCard.copyWith(
        id: const Uuid().v4(),
        number: updatedCard.number ?? _paymentCard.number,
        type: updatedCard.type ?? _paymentCard.type,
        month: updatedCard.month ?? _paymentCard.month,
        year: updatedCard.year ?? _paymentCard.year,
        cvv: updatedCard.cvv ?? _paymentCard.cvv,
        name: updatedCard.name ?? _paymentCard.name,
        isDefault: updatedCard.isDefault ?? _paymentCard.isDefault,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _paymentCard = _paymentCard.copyWith(type: CardType.others);
    _cardNumberController.addListener(_getCardTypeFrmNumber);
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _cardNumberController.removeListener(_getCardTypeFrmNumber);
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff000000).withValues(alpha: 0.05),
              blurRadius: 5.4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(44),
        child: AppButton.primary(
          onPressed: _isAllFieldsFilled() ? _validateInputs : null,
          text: 'ADD',
        ),
      ),
      appBar: AppBar(
        leading: const BackArrowWidget(),
        title: TextWidget(
          'Add New Card',
          style: AppTextStyles.bodyLargeBold.copyWith(
            color: context.colors.primaryText,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidateMode,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpaces.xxlarge),
              TextWidget(
                'Enter card details',
                style: AppTextStyles.h3.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpaces.onSides),
              AppTextFormFieldComponent(
                hintText: 'Enter card number',
                controller: _cardNumberController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CardUtils.getCardIcon(_paymentCard.type),
                ),
                validator: CardUtils.validateCardNum,
                keyboardType: TextInputType.number,
                onSaved: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    PaymentCard updatedCard = _paymentCard.copyWith(
                      number: CardUtils.getCleanedNumber(value),
                      type: CardUtils.getCardTypeFrmNumber(value),
                    );
                    updatePaymentCard(updatedCard);
                  }
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  CardNumberInputFormatter(),
                ],
              ),
              const SizedBox(height: AppSpaces.onSides),
              SizedBox(
                width: width,
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextFormFieldComponent(
                        hintText: 'Expiry',
                        // hintText: 'MM/YY',
                        controller: _expiryDateController,
                        validator: CardUtils.validateDate,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          if (value != null && value.isNotEmpty) {
                            List<int> expiryDate = CardUtils.getExpiryDate(
                              value,
                            );
                            PaymentCard updatedCard = _paymentCard.copyWith(
                              month: expiryDate[0],
                              year: expiryDate[1],
                            );
                            updatePaymentCard(updatedCard);
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          CardMonthInputFormatter(),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpaces.onSides),
                    Expanded(
                      child: AppTextFormFieldComponent(
                        hintText: 'CVV code',
                        controller: _cvvController,
                        validator: CardUtils.validateCVV,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          if (value != null && value.isNotEmpty) {
                            PaymentCard updatedCard = _paymentCard.copyWith(
                              cvv: int.parse(value),
                            );
                            updatePaymentCard(updatedCard);
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 46),
              TextWidget(
                'Save card for later',
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      'for faster and more secure checkout, save your card details',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmallBold.copyWith(
                        color: context.colors.tertiaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpaces.large),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _saveForLater,
                      onChanged: (value) {
                        setState(() {
                          _saveForLater = value;
                        });
                      },
                      activeThumbColor: context.colors.surface,
                      activeTrackColor: context.colors.primary,
                      inactiveThumbColor: context.colors.surface,
                      inactiveTrackColor: context.colors.surfaceDim,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
