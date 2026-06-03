import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:avis_package/src/features/_features.dart'
    show
        ReviewTripPageArgs,
        ReviewTripUiModel,
        ReviewTripUiModelFactory,
        ReviewTripProvider,
        TripBottomBarWidget,
        TripHeaderWidget,
        TripOptionsWidget,
        TripActionsWidget,
        PaymentProvider;

import 'package:avis_package/src/features/payment/views/payment_screen.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        AppContextExtension,
        AppTextStyles,
        SvgIconWidget,
        TextWidget,
        BackArrowWidget,
        AppSpaces,
        HorizontalDivider,
        TripRouteWidget,
        AppCustomDropdown,
        AppTextFormFieldComponent,
        AppRoutes,
        AvisNavigation,
        FlightNameModel;

class ReviewTripPage extends StatefulWidget {
  const ReviewTripPage({super.key});

  @override
  State<ReviewTripPage> createState() => _ReviewTripPageState();
}

class _ReviewTripPageState extends State<ReviewTripPage> {
  ReviewTripUiModel _modelFromRoute() {
    final args =
        ModalRoute.of(context)?.settings.arguments as ReviewTripPageArgs?;
    if (args != null && args.vehicles.isNotEmpty) {
      return args.toReviewTripUiModel();
    }
    return ReviewTripUiModelFactory.getFakeData();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ReviewTripProvider>();
      final args =
          ModalRoute.of(context)?.settings.arguments as ReviewTripPageArgs?;
      provider.initialize(args: args, model: _modelFromRoute());
      provider.loadFlightNames('ar');
      provider.loadCustomerInfoForFlightFields();
      provider.fetchChauffeurServicePrice();
    });
  }

  Future<void> _onConfirm(
    BuildContext context,
    ReviewTripProvider provider,
    ReviewTripUiModel model,
  ) async {
    final result = await provider.confirmBooking();
    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Could not confirm booking.')),
      );
      return;
    }

    final tripId = result.tripId!;
    final paymentUrl =
        'http://94.249.88.254:1040/ChauffeurService/ChauffeurPayment?TripId=$tripId&f=0&RequestSource=3';

    final isPaymentSuccess = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(paymentUrl: paymentUrl),
          ),
        ) ??
        false;

    if (!mounted) return;
    if (!isPaymentSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment was not completed. Please try again.'),
        ),
      );
      return;
    }

    context.read<PaymentProvider>().markPaidConfirmedFromWebView();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Finalizing your booking...'),
        backgroundColor: Colors.green,
      ),
    );

    await provider.refreshCustomerInfoAfterBooking();
    if (!mounted) return;

    Navigator.pop(context);
    AvisNavigation.push(
      context,
      AppRoutes.rideRequest,
      arguments: {'tripModel': result.tripModel, 'tripId': tripId},
    );
  }

  Future<void> _openTermsAndConditions() async {
    final uri = Uri.parse(ReviewTripProvider.termsUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Terms & Conditions.')),
      );
    }
  }

  void _showCurrencyPicker(BuildContext context, ReviewTripProvider provider) {
    if (provider.displayPrices.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextWidget(
                  'Select currency',
                  style: AppTextStyles.bodyLargeBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                ),
              ),
              ...List.generate(provider.displayPrices.length, (i) {
                final item = provider.displayPrices[i];
                final selected = i == provider.selectedDisplayPriceIndex;
                return ListTile(
                  title: TextWidget(
                    '${item.currencyCode} - ${provider.currencySymbol(item.currencyCode)}${item.totalWithTax.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: selected
                          ? context.colors.primary
                          : context.colors.primaryText,
                    ),
                  ),
                  onTap: () {
                    provider.selectDisplayPriceIndex(i);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitleWithPrice(
    BuildContext context,
    ReviewTripProvider provider, {
    required String title,
    double? price,
    double? discountPercent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextWidget(
              title,
              style: AppTextStyles.h3.copyWith(
                color: context.colors.primaryText,
              ),
            ),
          ),
          if (provider.loadingPrice)
            TextWidget(
              '...',
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: context.colors.tertiaryText,
              ),
            )
          else if (price != null)
            TextWidget(
              provider.formatLegPriceLabel(
                price,
                discountPercent: discountPercent,
              ),
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: context.colors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditionsRow(
    BuildContext context,
    ReviewTripProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: provider.acceptedTerms,
            onChanged: (v) => provider.setAcceptedTerms(v ?? false),
            activeColor: context.colors.primary,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.colors.secondaryText,
                  ),
                  children: [
                    const TextSpan(text: 'I accept '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: AppTextStyles.bodySmallBold.copyWith(
                        color: context.colors.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _openTermsAndConditions,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundTripDetailsSection(
    BuildContext context,
    ReviewTripProvider provider,
    ReviewTripPageArgs args,
  ) {
    final returnDate = args.returnDate ?? '';
    final returnTime = args.returnTime ?? '';
    final returnPickupLocation = args.dropOffPlaceName.isEmpty
        ? 'Pickup location'
        : args.dropOffPlaceName;
    final returnDropOffLocation = args.fromPlaceName.isEmpty
        ? 'Drop-off location'
        : args.fromPlaceName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpaces.large),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SvgIconWidget(
                name: 'calendar',
                width: 22,
                height: 22,
                color: context.colors.tertiaryText,
              ),
              const SizedBox(width: 8),
              TextWidget(
                '$returnDate at $returnTime',
                style: AppTextStyles.bodyLargeBold.copyWith(
                  color: context.colors.tertiaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpaces.large),
        _buildSectionTitleWithPrice(
          context,
          provider,
          title: 'Round trip details',
          price: provider.roundTripLegPrice,
          discountPercent: provider.roundTripLegPriceDiscount,
        ),
        const SizedBox(height: AppSpaces.large),
        TripRouteWidget(
          pickupLabel: 'Pick up details',
          pickupTime: returnTime,
          pickupLocation: returnPickupLocation,
          dropOffLabel: 'Drop off details',
          dropOffLocation: returnDropOffLocation,
        ),
      ],
    );
  }

  Widget _buildMeetAssistFlightSection(
    BuildContext context,
    ReviewTripProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCustomDropdown<FlightNameModel>(
            title: '',
            items: provider.flightNames,
            selectedValue: provider.selectedFlightName,
            onChanged: provider.setSelectedFlightName,
            itemAsString: (f) => f.displayName,
            hintText: provider.loadingFlightNames ? 'Loading...' : 'Select Airline',
            height: 56,
            selectedTextStyle: AppTextStyles.bodyMediumBold.copyWith(
              color: context.colors.primaryText,
            ),
            iconWidget: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SvgIconWidget(
                name: 'Airport',
                width: 20,
                height: 20,
                color: context.colors.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: AppSpaces.medium),
          AppTextFormFieldComponent(
            controller: provider.flightNumberController,
            hintText: 'Flight number',
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            focusedBorderSameAsEnabled: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpaces.onSides,
              horizontal: AppSpaces.medium,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: AppSpaces.onSides),
              child: SvgIconWidget(
                name: 'Airport',
                width: 20,
                height: 20,
                color: context.colors.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: AppSpaces.medium),
          AppTextFormFieldComponent(
            controller: provider.frequentFlyerNumberController,
            hintText: 'Frequent Flyer Number',
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            focusedBorderSameAsEnabled: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpaces.onSides,
              horizontal: AppSpaces.medium,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: AppSpaces.onSides),
              child: SvgIconWidget(
                name: 'Airport',
                width: 20,
                height: 20,
                color: context.colors.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: AppSpaces.medium),
          AppTextFormFieldComponent(
            controller: provider.eTicketNumberController,
            hintText: 'E-ticket Number',
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            focusedBorderSameAsEnabled: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpaces.onSides,
              horizontal: AppSpaces.medium,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: AppSpaces.onSides),
              child: SvgIconWidget(
                name: 'Airport',
                width: 20,
                height: 20,
                color: context.colors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as ReviewTripPageArgs?;
    final model = _modelFromRoute();

    return Consumer<ReviewTripProvider>(
      builder: (context, provider, _) {
        final options = provider.buildOptions();
        final displayPrice = provider.displayPrice(model);

        return Scaffold(
          bottomNavigationBar: TripBottomBarWidget(
            price: displayPrice,
            buttonText: provider.confirming
                ? 'Confirming...'
                : provider.loadingPrice
                    ? 'Loading price...'
                    : model.confirmButtonText,
            isIndividual: model.isIndividual,
            onConfirm: (provider.confirming || provider.loadingPrice)
                ? null
                : () => _onConfirm(context, provider, model),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: const BackArrowWidget(),
                title: Text(
                  'Review Trip',
                  style: AppTextStyles.bodyLargeBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                ),
                backgroundColor: context.colors.outline,
                floating: true,
                pinned: true,
                snap: true,
                toolbarHeight: kToolbarHeight,
                expandedHeight: 161,
                flexibleSpace: FlexibleSpaceBar(
                  background: TripHeaderWidget(
                    vehicle: model.vehicle,
                    price: displayPrice,
                    isIndividual: model.isIndividual,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  const SizedBox(height: 13.5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SvgIconWidget(
                          name: 'calendar',
                          width: 22,
                          height: 22,
                          color: context.colors.tertiaryText,
                        ),
                        const SizedBox(width: 8),
                        TextWidget(
                          model.formattedDateTime,
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            color: context.colors.tertiaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpaces.large),
                  _buildSectionTitleWithPrice(
                    context,
                    provider,
                    title: model.route.pickupLabel,
                    price: provider.pickupLegPrice,
                  ),
                  const SizedBox(height: AppSpaces.large),
                  TripRouteWidget(
                    pickupLabel: model.route.pickupLabel,
                    pickupTime: model.route.pickupTime,
                    pickupLocation: model.route.pickupLocation,
                    dropOffLabel: model.route.dropOffLabel,
                    dropOffLocation: model.route.dropOffLocation,
                  ),
                  if (args?.isRoundTrip == true)
                    _buildRoundTripDetailsSection(context, provider, args!),
                  if (options.isNotEmpty) ...[
                    const SizedBox(height: AppSpaces.large),
                    const HorizontalDivider(),
                    const SizedBox(height: AppSpaces.large),
                    TripOptionsWidget(options: options),
                  ],
                  if (model.isIndividual) ...[
                    const SizedBox(height: AppSpaces.large),
                    const HorizontalDivider(),
                    const SizedBox(height: AppSpaces.large),
                    if (provider.showFlightInfoFields(args)) ...[
                      _buildMeetAssistFlightSection(context, provider),
                      const SizedBox(height: AppSpaces.large),
                    ],
                    TripActionsWidget(
                      actions: model.actions,
                      tripTypeId: args?.tripTypeId ?? 7,
                      appliedPromoCode: provider.appliedPromoCode,
                      onPromoCodeApplied: provider.applyPromoCode,
                      onPromoCodeRemoved: provider.removePromoCode,
                      loyaltyTotalPoints: args?.totalLoyalityPoints,
                      loyaltyMaxRedeemablePoints: args?.maxRedeemablePoints,
                      loyaltyMinRedeemablePoints:
                          args?.minimumPointsValueForTransfer,
                      appliedLoyaltyCode: provider.appliedLoyaltyCode,
                      onLoyaltyRedeemed: provider.applyLoyaltyCode,
                      onLoyaltyRemoved: provider.removeLoyaltyCode,
                    ),
                    const SizedBox(height: AppSpaces.large),
                    if (provider.displayPrices.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Material(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _showCurrencyPicker(context, provider),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: AppSpaces.medium,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: context.colors.inputBorder,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  TextWidget(
                                    'Currency: ${provider.displayPrices[provider.selectedDisplayPriceIndex].currencyCode}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: context.colors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextWidget(
                                      '${provider.currencySymbol(provider.displayPrices[provider.selectedDisplayPriceIndex].currencyCode)}${(provider.priceFromApi ?? 0).toStringAsFixed(2)}',
                                      style: AppTextStyles.bodyMediumBold.copyWith(
                                        color: context.colors.primaryText,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 24,
                                    color: context.colors.tertiaryText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpaces.large),
                    ],
                    _buildTermsAndConditionsRow(context, provider),
                    const SizedBox(height: AppSpaces.large),
                  ],
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
