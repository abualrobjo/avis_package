import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/_features.dart';

class ReviewTripProvider extends ChangeNotifier {
  ReviewTripProvider(
    this._authLocalService,
    this._chauffeurServicePricesService,
    this._chauffeurRequestService,
    this._customerInfoService,
    this._flightNamesService,
  );

  static const int companyId = 1;
  static const String termsUrl = 'http://94.249.88.254:1040/TermsAndConditions';

  final AuthLocalService _authLocalService;
  final ChauffeurServicePricesService _chauffeurServicePricesService;
  final ChauffeurRequestService _chauffeurRequestService;
  final CustomerInfoService _customerInfoService;
  final FlightNamesService _flightNamesService;

  ReviewTripPageArgs? _args;
  ReviewTripUiModel? _model;

  List<bool> _optionEnabled = [];
  bool _confirming = false;
  double? _priceFromApi;
  bool _loadingPrice = false;
  List<DisplayPriceItem> _displayPrices = [];
  int _selectedDisplayPriceIndex = 0;
  double? _fallbackOrginalMinPrice;
  double? _fallbackReturnTripPrice;
  double? _fallbackReturnTripPriceDiscount;
  double? _fallbackTaxAmount;
  String? _appliedPromoCode;
  CheckPromoCodeValidityDetails? _appliedPromoDetails;
  String? _appliedLoyaltyCode;
  List<FlightNameModel> _flightNames = [];
  bool _loadingFlightNames = false;
  FlightNameModel? _selectedFlightName;
  CustomerInfoModel? _cachedCustomerInfo;
  bool _acceptedTerms = false;

  final TextEditingController flightNumberController = TextEditingController();
  final TextEditingController frequentFlyerNumberController =
      TextEditingController();
  final TextEditingController eTicketNumberController = TextEditingController();

  ReviewTripPageArgs? get args => _args;
  ReviewTripUiModel? get model => _model;
  bool get confirming => _confirming;
  bool get loadingPrice => _loadingPrice;
  List<DisplayPriceItem> get displayPrices => _displayPrices;
  int get selectedDisplayPriceIndex => _selectedDisplayPriceIndex;
  String? get appliedPromoCode => _appliedPromoCode;
  CheckPromoCodeValidityDetails? get appliedPromoDetails => _appliedPromoDetails;
  String? get appliedLoyaltyCode => _appliedLoyaltyCode;
  List<FlightNameModel> get flightNames => _flightNames;
  bool get loadingFlightNames => _loadingFlightNames;
  FlightNameModel? get selectedFlightName => _selectedFlightName;
  bool get acceptedTerms => _acceptedTerms;
  double? get priceFromApi => _priceFromApi;

  DisplayPriceItem? get selectedDisplayPrice {
    if (_displayPrices.isEmpty) return null;
    final index = _selectedDisplayPriceIndex;
    if (index < 0 || index >= _displayPrices.length) return null;
    return _displayPrices[index];
  }

  double? get displayTaxAmount =>
      selectedDisplayPrice?.taxAmount ?? _fallbackTaxAmount;

  double? get pickupLegPrice =>
      selectedDisplayPrice?.orginalMinPrice ?? _fallbackOrginalMinPrice;

  double? get roundTripLegPrice =>
      selectedDisplayPrice?.returnTripPrice ?? _fallbackReturnTripPrice;

  double? get roundTripLegPriceDiscount =>
      selectedDisplayPrice?.returnTripPriceDiscount ??
      _fallbackReturnTripPriceDiscount;

  bool showFlightInfoFields(ReviewTripPageArgs? pageArgs) =>
      pageArgs?.tripTypeId == 1 ||
      _appliedPromoDetails?.isRelatedToFlight == true ||
      _appliedPromoDetails?.isFreeRide == true;

  ReviewTripPriceUiModel displayPrice(ReviewTripUiModel baseModel) {
    return ReviewTripPriceUiModel(
      amount: _priceFromApi ?? baseModel.price.amount,
      currency: _displayPrices.isNotEmpty
          ? _displayPrices[_selectedDisplayPriceIndex].currencyCode
          : baseModel.price.currency,
      label: baseModel.price.label,
      taxAmount: _priceFromApi != null ? displayTaxAmount : null,
    );
  }

  void initialize({
    required ReviewTripPageArgs? args,
    required ReviewTripUiModel model,
  }) {
    _args = args;
    _model = model;
    _optionEnabled = model.options.map((o) => o.isEnabled).toList();
    notifyListeners();
  }

  List<ReviewTripOptionUiModel> buildOptions() {
    final tripModel = _model;
    if (tripModel == null || tripModel.options.isEmpty) return [];

    final meetIndex = tripModel.options
        .indexWhere((o) => o.title.toLowerCase().contains('meet'));
    final curbIndex = tripModel.options
        .indexWhere((o) => o.title.toLowerCase().contains('curb'));

    return List.generate(tripModel.options.length, (i) {
      final o = tripModel.options[i];
      return ReviewTripOptionUiModel(
        iconName: o.iconName,
        title: o.title,
        isEnabled: i < _optionEnabled.length ? _optionEnabled[i] : o.isEnabled,
        onChanged: (value) => _toggleOption(
          index: i,
          value: value,
          meetIndex: meetIndex,
          curbIndex: curbIndex,
        ),
        isSelectable: true,
      );
    });
  }

  void _toggleOption({
    required int index,
    required bool value,
    required int meetIndex,
    required int curbIndex,
  }) {
    if (index >= _optionEnabled.length) return;
    _optionEnabled[index] = value;
    if (value && index == meetIndex && curbIndex >= 0) {
      _optionEnabled[curbIndex] = false;
    }
    if (value && index == curbIndex && meetIndex >= 0) {
      _optionEnabled[meetIndex] = false;
    }
    notifyListeners();
    fetchChauffeurServicePrice();
  }

  bool _optionValue(List<ReviewTripOptionUiModel> options, String titleContains) {
    final i = options.indexWhere(
      (o) => o.title.toLowerCase().contains(titleContains.toLowerCase()),
    );
    if (i < 0 || i >= _optionEnabled.length) return false;
    return _optionEnabled[i];
  }

  void setAcceptedTerms(bool value) {
    _acceptedTerms = value;
    notifyListeners();
  }

  void setSelectedFlightName(FlightNameModel? value) {
    _selectedFlightName = value;
    notifyListeners();
  }

  void applyPromoCode(String code, CheckPromoCodeValidityDetails details) {
    _appliedPromoCode = code;
    _appliedPromoDetails = details;
    notifyListeners();
    fetchChauffeurServicePrice();
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _appliedPromoDetails = null;
    notifyListeners();
    fetchChauffeurServicePrice();
  }

  void applyLoyaltyCode(String code) {
    _appliedLoyaltyCode = code;
    notifyListeners();
    fetchChauffeurServicePrice();
  }

  void removeLoyaltyCode() {
    _appliedLoyaltyCode = null;
    notifyListeners();
    fetchChauffeurServicePrice();
  }

  void selectDisplayPriceIndex(int index) {
    if (index < 0 || index >= _displayPrices.length) return;
    _selectedDisplayPriceIndex = index;
    _priceFromApi = _displayPrices[index].totalWithTax;
    notifyListeners();
  }

  String? validateBeforeConfirm() {
    if (!_acceptedTerms) {
      return 'Please accept Terms & Conditions before confirming.';
    }
    final pageArgs = _args;
    if (pageArgs == null || pageArgs.vehicles.isEmpty) {
      return 'Missing trip details. Please start from the booking page.';
    }
    final requireDropOff = pageArgs.tripTypeConfig?.allowDropOff ?? true;
    if (pageArgs.pickupLatLng == null ||
        (requireDropOff && pageArgs.dropOffLatLng == null)) {
      return 'Pickup and drop-off locations are required.';
    }
    return _validatePromoBookingRequirements();
  }

  String? _validatePromoBookingRequirements() {
    final promo = _appliedPromoDetails;
    if (_appliedPromoCode == null || promo == null) return null;

    if (promo.isFreeRide && _trimmedTextOrNull(eTicketNumberController.text) == null) {
      return 'Please enter E-ticket number for this promo code.';
    }

    if (promo.isRelatedToFlight) {
      if (_selectedFlightName == null) {
        return 'Please select an airline for this promo code.';
      }
      if (_trimmedTextOrNull(frequentFlyerNumberController.text) == null) {
        return 'Please enter Frequent Flyer Number for this promo code.';
      }
    }

    return null;
  }

  Future<ReviewTripBookingResult> confirmBooking() async {
    final pageArgs = _args;
    final tripModel = _model;
    if (pageArgs == null || tripModel == null) {
      return ReviewTripBookingResult.failure(
        'Missing trip details. Please start from the booking page.',
      );
    }

    final validationError = validateBeforeConfirm();
    if (validationError != null) {
      return ReviewTripBookingResult.failure(validationError);
    }

    final options = buildOptions();
    final vehicle = pageArgs.vehicles.first;
    final haveMeetGreet = _optionValue(options, 'meet');
    final onCurb = _optionValue(options, 'curb');
    final isWifiRequired = _optionValue(options, 'wifi');
    final requireDropOff = pageArgs.tripTypeConfig?.allowDropOff ?? true;
    final dropOffLat = requireDropOff ? pageArgs.dropOffLatLng! : null;

    final body = BookChauffeurRequestBody(
      companyId: companyId,
      customerId:
          _authLocalService.getUserId() ?? AppConst.fallbackCustomerId,
      branchId: pageArgs.branchId,
      requestSourceId: 2,
      requestStatusId: 7,
      tripTypeId: pageArgs.tripTypeId,
      pickupLatitude: pageArgs.fromPlaceName,
      pickupLongtitude:
          '${pageArgs.pickupLatLng!.latitude},${pageArgs.pickupLatLng!.longitude}',
      dropOffLatitude: pageArgs.dropOffPlaceName,
      dropOffLongtitude: dropOffLat != null
          ? '${dropOffLat.latitude},${dropOffLat.longitude}'
          : '0,0',
      tripsHour: pageArgs.isByDay ? null : pageArgs.durationHours,
      tripsDay: pageArgs.isByDay ? pageArgs.durationHours : null,
      haveMeetGreet: haveMeetGreet,
      isWifiRequired: isWifiRequired,
      fromZoneId: pageArgs.fromZoneId,
      toZoneId: pageArgs.toZoneId,
      classId: vehicle.classId,
      onCurb: onCurb,
      tripDateTime: pageArgs.tripDateTimeApiString,
      returnTripDateTime:
          pageArgs.isRoundTrip ? pageArgs.returnTripDateTimeApiString : null,
      tripDurationMinutes: pageArgs.durationHours * 60,
      promoCode: _appliedPromoCode,
      loyalityRedeemCode: _appliedLoyaltyCode,
      isDropoffAirport: pageArgs.isDropoffAirport,
      isHalfDay: pageArgs.isHalfDay,
      isRoundTrip: pageArgs.isRoundTrip,
      isPerDay: pageArgs.isByDay,
      frequentFlyerNumber:
          _trimmedTextOrNull(frequentFlyerNumberController.text),
      eTicketNumber: _trimmedTextOrNull(eTicketNumberController.text),
    );

    _confirming = true;
    notifyListeners();

    final response = await _chauffeurRequestService.bookChauffeurRequest(body);

    _confirming = false;
    notifyListeners();

    if (!response.isSuccess) {
      return ReviewTripBookingResult.failure(
        response.errorMessage ?? 'Could not confirm booking.',
      );
    }

    final tripId = response.data.id;
    if (tripId <= 0) {
      return ReviewTripBookingResult.failure(
        'Booking failed: no trip id returned.',
      );
    }

    return ReviewTripBookingResult.success(
      tripId: tripId,
      tripModel: _tripModelForRideRequest(tripModel),
    );
  }

  Future<void> fetchChauffeurServicePrice() async {
    final pageArgs = _args;
    final tripModel = _model;
    if (pageArgs == null || pageArgs.vehicles.isEmpty || tripModel == null) {
      return;
    }

    final options = buildOptions();
    final haveMeetGreet = _optionValue(options, 'meet');
    final onCurb = _optionValue(options, 'curb');
    final isWifiRequired = _optionValue(options, 'wifi');
    final vehicle = pageArgs.vehicles.first;

    final body = ChauffeurServicePricesByRequestBody(
      companyId: companyId,
      customerId:
          _authLocalService.getUserId() ?? AppConst.fallbackCustomerId,
      tripTypeId: pageArgs.tripTypeId,
      tripsHour: pageArgs.isByDay ? null : pageArgs.durationHours,
      tripsDay: pageArgs.isByDay ? pageArgs.durationHours : null,
      haveMeetGreet: haveMeetGreet,
      isWifiRequired: isWifiRequired,
      useCompanyPricing: false,
      fromZoneId: pageArgs.fromZoneId,
      toZoneId: pageArgs.toZoneId,
      vehicleClassId: vehicle.classId,
      onCurb: onCurb,
      isDropoffAirport: pageArgs.isDropoffAirport,
      tripDateTime: pageArgs.tripDateTimeApiString,
      returnDate: _returnDateForPricesRequest(pageArgs),
      tripDurationMinutes: pageArgs.durationHours * 60,
      branchId: pageArgs.branchId,
      promoCode: _appliedPromoCode,
      applicableApplication: 2,
      loyalityRedeemCode: _appliedLoyaltyCode,
    );

    _loadingPrice = true;
    notifyListeners();

    final response =
        await _chauffeurServicePricesService.getChauffeurServicePricesByRequest(
      body,
    );

    _loadingPrice = false;
    if (response.isSuccess) {
      final previousCurrencyCode = _displayPrices.isNotEmpty
          ? _displayPrices[_selectedDisplayPriceIndex].currencyCode
          : null;
      _priceFromApi = response.data.totalWithTax;
      _displayPrices = response.data.displayPrices;
      _fallbackOrginalMinPrice = response.data.orginalMinPrice;
      _fallbackReturnTripPrice = response.data.returnTripPrice;
      _fallbackReturnTripPriceDiscount = response.data.returnTripPriceDiscount;
      _fallbackTaxAmount = response.data.taxAmount;
      if (_displayPrices.isNotEmpty) {
        var nextIndex = 0;
        if (previousCurrencyCode != null) {
          final sameCurrencyIndex = _displayPrices.indexWhere(
            (item) => item.currencyCode == previousCurrencyCode,
          );
          if (sameCurrencyIndex >= 0) {
            nextIndex = sameCurrencyIndex;
          }
        }
        _selectedDisplayPriceIndex = nextIndex;
        _priceFromApi = _displayPrices[_selectedDisplayPriceIndex].totalWithTax;
      }
    }
    notifyListeners();
  }

  Future<void> loadFlightNames(String language) async {
    if (_loadingFlightNames) return;
    _loadingFlightNames = true;
    notifyListeners();

    final result = await _flightNamesService.getFlightNames(language);

    _loadingFlightNames = false;
    if (result.isSuccess && result.data.isNotEmpty) {
      _flightNames = result.data;
    }
    notifyListeners();

    final cached = _cachedCustomerInfo;
    if (cached != null) {
      _applyCustomerFlightInfo(cached);
    }
  }

  Future<void> loadCustomerInfoForFlightFields() async {
    final customerId =
        _authLocalService.getUserId() ?? AppConst.fallbackCustomerId;
    final result = await _customerInfoService.getCustomerInfo(customerId);
    if (!result.isSuccess) return;
    _cachedCustomerInfo = result.data;
    _applyCustomerFlightInfo(result.data);
  }

  Future<void> refreshCustomerInfoAfterBooking() async {
    final customerId =
        _authLocalService.getUserId() ?? AppConst.fallbackCustomerId;
    await _customerInfoService.getCustomerInfo(customerId);
  }

  String formatLegPrice(double amount) {
    final code = selectedDisplayPrice?.currencyCode ?? '';
    return '${currencySymbol(code)}${amount.toStringAsFixed(2)}';
  }

  String formatLegPriceLabel(double price, {double? discountPercent}) {
    final formatted = formatLegPrice(price);
    if (discountPercent == null) return formatted;
    return '$formatted (${_formatDiscountPercent(discountPercent)})';
  }

  String currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'JOD':
        return 'JOD ';
      case 'EGP':
        return 'EGP ';
      default:
        return '$code ';
    }
  }

  ReviewTripUiModel _tripModelForRideRequest(ReviewTripUiModel baseModel) {
    return ReviewTripUiModel(
      isIndividual: baseModel.isIndividual,
      date: baseModel.date,
      time: baseModel.time,
      route: baseModel.route,
      vehicle: baseModel.vehicle,
      price: ReviewTripPriceUiModel(
        amount: _priceFromApi ?? baseModel.price.amount,
        currency: _displayPrices.isNotEmpty
            ? _displayPrices[_selectedDisplayPriceIndex].currencyCode
            : baseModel.price.currency,
        label: baseModel.price.label,
        taxAmount: _priceFromApi != null ? displayTaxAmount : null,
      ),
      options: baseModel.options,
      actions: baseModel.actions,
      confirmButtonText: baseModel.confirmButtonText,
    );
  }

  String? _returnDateForPricesRequest(ReviewTripPageArgs pageArgs) {
    if (!pageArgs.isRoundTrip) return null;
    final apiDateTime = pageArgs.returnTripDateTimeApiString;
    if (apiDateTime == null || apiDateTime.isEmpty) return null;
    final dt = DateTime.tryParse(apiDateTime);
    if (dt == null) return null;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  void _applyCustomerFlightInfo(CustomerInfoModel info) {
    final frequentFlyer = info.frequentFlyerNumber?.trim();
    if (frequentFlyer != null && frequentFlyer.isNotEmpty) {
      frequentFlyerNumberController.text = frequentFlyer;
    }

    final airlineId = info.airlineId;
    if (airlineId != null && _flightNames.isNotEmpty) {
      final match = _flightNames.where((f) => f.id == airlineId).firstOrNull;
      if (match != null) {
        _selectedFlightName = match;
      }
    }

    notifyListeners();
  }

  String? _trimmedTextOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDiscountPercent(double discount) {
    if (discount == discount.truncateToDouble()) {
      return '${discount.toInt()}%';
    }
    return '${discount.toStringAsFixed(1)}%';
  }

  @override
  void dispose() {
    flightNumberController.dispose();
    frequentFlyerNumberController.dispose();
    eTicketNumberController.dispose();
    super.dispose();
  }
}

class ReviewTripBookingResult {
  const ReviewTripBookingResult._({
    required this.success,
    this.tripId,
    this.tripModel,
    this.errorMessage,
  });

  factory ReviewTripBookingResult.success({
    required int tripId,
    required ReviewTripUiModel tripModel,
  }) {
    return ReviewTripBookingResult._(
      success: true,
      tripId: tripId,
      tripModel: tripModel,
    );
  }

  factory ReviewTripBookingResult.failure(String message) {
    return ReviewTripBookingResult._(
      success: false,
      errorMessage: message,
    );
  }

  final bool success;
  final int? tripId;
  final ReviewTripUiModel? tripModel;
  final String? errorMessage;
}
