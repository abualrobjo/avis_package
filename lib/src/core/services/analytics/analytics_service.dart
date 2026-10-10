import 'dart:developer';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:customer_io/customer_io.dart';
import 'package:customer_io/customer_io_config.dart';
import 'package:customer_io/customer_io_enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Which SDKs receive one unified event from the tracking sheet.
class AnalyticsEvent {
  const AnalyticsEvent(
    this.name, {
    required this.mixpanel,
    required this.adjust,
    required this.customerIo,
  });

  final String name;
  final bool mixpanel;
  final bool adjust;
  final bool customerIo;
}

/// Event names and SDK routing from the analytics specification.
class AnalyticsEvents {
  const AnalyticsEvents._();

  static const appInstalled = AnalyticsEvent(
    'App_Installed',
    mixpanel: true,
    adjust: true,
    customerIo: false,
  );
  static const appOpened = AnalyticsEvent(
    'App_Opened',
    mixpanel: true,
    adjust: true,
    customerIo: true,
  );
  static const signupStarted = AnalyticsEvent(
    'Signup_Started',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );
  static const signupCompleted = AnalyticsEvent(
    'Signup_Completed',
    mixpanel: true,
    adjust: true,
    customerIo: true,
  );
  static const userLoggedIn = AnalyticsEvent(
    'User_Logged_In',
    mixpanel: true,
    adjust: true,
    customerIo: true,
  );
  static const serviceType = AnalyticsEvent(
    'Service_type',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );
  static const locationSelected = AnalyticsEvent(
    'Location_Selected',
    mixpanel: true,
    adjust: false,
    customerIo: false,
  );
  static const datesSelected = AnalyticsEvent(
    'Dates_Selected',
    mixpanel: true,
    adjust: false,
    customerIo: false,
  );
  static const tripType = AnalyticsEvent(
    'Trip_type',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );
  static const chooseVehicle = AnalyticsEvent(
    'Choose_vehicle',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );
  static const searchPerformed = AnalyticsEvent(
    'Search_Performed',
    mixpanel: false,
    adjust: true,
    customerIo: false,
  );
  static const vehicleSelected = AnalyticsEvent(
    'Vehicle_Selected',
    mixpanel: true,
    adjust: true,
    customerIo: true,
  );
  static const confirmRide = AnalyticsEvent(
    'Confirm_Ride',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );
  static const checkoutInitiated = AnalyticsEvent(
    'Checkout_Initiated',
    mixpanel: false,
    adjust: true,
    customerIo: false,
  );
  static const promoCodeApplied = AnalyticsEvent(
    'Promo_Code_Applied',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );
  static const cartAbandoned = AnalyticsEvent(
    'Cart_Abandoned',
    mixpanel: true,
    adjust: true,
    customerIo: true,
  );
  static const bookingCompleted = AnalyticsEvent(
    'Booking_Completed',
    mixpanel: true,
    adjust: true,
    customerIo: true,
  );
  static const bookingCancelled = AnalyticsEvent(
    'Booking_Cancelled',
    mixpanel: true,
    adjust: true,
    customerIo: true,
  );
  static const ratingSubmitted = AnalyticsEvent(
    'Rating_Submitted',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );
  static const feedbackSubmitted = AnalyticsEvent(
    'Feedback_Submitted',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );
  static const paymentInfoEntered = AnalyticsEvent(
    'Payment_Info_Entered',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );

  /// Spelling matches the tracking sheet.
  static const paymentStatus = AnalyticsEvent(
    'Paymnet_status',
    mixpanel: true,
    adjust: false,
    customerIo: true,
  );
  static const rentalCompleted = AnalyticsEvent(
    'Rental_Completed',
    mixpanel: false,
    adjust: true,
    customerIo: false,
  );
}

/// Starts Customer.io, Adjust, and Mixpanel, then sends spec events
/// only to the SDKs marked yes for that event.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  static const _installFlagKey = 'analytics_app_installed';

  Mixpanel? _mixpanel;
  bool _customerIoReady = false;
  bool _adjustReady = false;
  int? _identifiedCustomerId;

  Future<void> initialize() async {
    await Future.wait([
      _initCustomerIo(),
      _initAdjust(),
      _initMixpanel(),
    ]);
  }

  /// Call after Hive `settings_box` is open.
  Future<void> trackAppLifecycle() async {
    await track(AnalyticsEvents.appOpened);
    if (!Hive.isBoxOpen('settings_box')) return;
    final box = Hive.box('settings_box');
    if (box.get(_installFlagKey) == true) return;
    await track(AnalyticsEvents.appInstalled);
    await box.put(_installFlagKey, true);
  }

  Future<void> identifyCustomer({
    required int customerId,
    String? name,
    String? email,
    String? phone,
  }) async {
    final userId = customerId.toString();
    final traits = <String, String>{
      if (_filled(name) != null) 'name': _filled(name)!,
      if (_filled(email) != null) 'email': _filled(email)!,
      if (_filled(phone) != null) 'phone': _filled(phone)!,
    };
    final isNewUser = _identifiedCustomerId != customerId;
    _identifiedCustomerId = customerId;

    if (_customerIoReady && (isNewUser || traits.isNotEmpty)) {
      CustomerIO.instance.identify(userId: userId, traits: traits);
    }

    final mixpanel = _mixpanel;
    if (mixpanel != null) {
      if (isNewUser) {
        await mixpanel.identify(userId);
      }
      final people = mixpanel.getPeople();
      final profileName = traits['name'];
      final profileEmail = traits['email'];
      final profilePhone = traits['phone'];
      if (profileName != null) people.set(r'$name', profileName);
      if (profileEmail != null) people.set(r'$email', profileEmail);
      if (profilePhone != null) people.set(r'$phone', profilePhone);
    }

    if (_adjustReady && isNewUser) {
      Adjust.addGlobalCallbackParameter('customer_id', userId);
    }

    if (isNewUser) {
      await track(
        AnalyticsEvents.userLoggedIn,
        properties: {'customer_id': customerId},
      );
    }
  }

  Future<void> track(
    AnalyticsEvent event, {
    Map<String, dynamic>? properties,
  }) async {
    final props = _withoutNulls(properties);
    if (event.mixpanel) {
      await _mixpanel?.track(event.name, properties: props);
    }
    if (event.customerIo && _customerIoReady) {
      CustomerIO.instance.track(name: event.name, properties: props);
    }
    if (event.adjust && _adjustReady) {
      _trackAdjust(event.name, props);
    }
  }

  void _trackAdjust(String eventName, Map<String, dynamic> properties) {
    final token = _filled(dotenv.env['ADJUST_EVENT_${eventName.toUpperCase()}']);
    if (token == null) {
      log('Adjust event $eventName skipped: ADJUST_EVENT_${eventName.toUpperCase()} is empty');
      return;
    }
    final adjustEvent = AdjustEvent(token);
    for (final entry in properties.entries) {
      adjustEvent.addCallbackParameter(entry.key, entry.value.toString());
    }
    Adjust.trackEvent(adjustEvent);
  }

  Future<void> _initCustomerIo() async {
    final apiKey = _filled(dotenv.env['CUSTOMER_IO_CDP_API_KEY']);
    if (apiKey == null) {
      log('Customer.io skipped: CUSTOMER_IO_CDP_API_KEY is empty');
      return;
    }

    final siteId = _filled(dotenv.env['CUSTOMER_IO_SITE_ID']);
    try {
      await CustomerIO.initialize(
        config: CustomerIOConfig(
          cdpApiKey: apiKey,
          region: _customerIoRegion(dotenv.env['CUSTOMER_IO_REGION']),
          logLevel: kDebugMode ? CioLogLevel.debug : CioLogLevel.error,
          trackApplicationLifecycleEvents: true,
          autoTrackDeviceAttributes: true,
          inAppConfig: siteId == null ? null : InAppConfig(siteId: siteId),
        ),
      );
      _customerIoReady = true;
      log('Customer.io initialized');
    } catch (error, stackTrace) {
      log('Customer.io initialization failed: $error', stackTrace: stackTrace);
    }
  }

  Future<void> _initAdjust() async {
    final appToken = _filled(dotenv.env['ADJUST_APP_TOKEN']);
    if (appToken == null) {
      log('Adjust skipped: ADJUST_APP_TOKEN is empty');
      return;
    }

    try {
      final config = AdjustConfig(appToken, _adjustEnvironment());
      config.logLevel = kDebugMode ? AdjustLogLevel.verbose : AdjustLogLevel.info;
      Adjust.initSdk(config);
      _adjustReady = true;
      log('Adjust initialized');
    } catch (error, stackTrace) {
      log('Adjust initialization failed: $error', stackTrace: stackTrace);
    }
  }

  Future<void> _initMixpanel() async {
    final token = _filled(dotenv.env['MIXPANEL_TOKEN']);
    if (token == null) {
      log('Mixpanel skipped: MIXPANEL_TOKEN is empty');
      return;
    }

    try {
      _mixpanel = await Mixpanel.init(
        token,
        trackAutomaticEvents: true,
        serverURL: _mixpanelServerUrl(dotenv.env['MIXPANEL_REGION']),
      );
      log('Mixpanel initialized');
    } catch (error, stackTrace) {
      log('Mixpanel initialization failed: $error', stackTrace: stackTrace);
    }
  }

  Region _customerIoRegion(String? value) {
    return value?.trim().toLowerCase() == 'eu' ? Region.eu : Region.us;
  }

  AdjustEnvironment _adjustEnvironment() {
    final value = dotenv.env['ADJUST_ENVIRONMENT']?.trim().toLowerCase();
    return value == 'production'
        ? AdjustEnvironment.production
        : AdjustEnvironment.sandbox;
  }

  String? _mixpanelServerUrl(String? region) {
    switch (region?.trim().toLowerCase()) {
      case 'eu':
        return 'https://api-eu.mixpanel.com';
      case 'in':
      case 'india':
        return 'https://api-in.mixpanel.com';
      default:
        return null;
    }
  }

  Map<String, dynamic> _withoutNulls(Map<String, dynamic>? properties) {
    if (properties == null || properties.isEmpty) return const {};
    return {
      for (final entry in properties.entries)
        if (entry.value != null) entry.key: entry.value,
    };
  }

  String? _filled(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
