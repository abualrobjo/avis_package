import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ReviewTripUiModel {
  final bool isIndividual;
  final String date;
  final String time;
  final ReviewTripRouteUiModel route;
  final ReviewTripVehicleUiModel vehicle;
  final ReviewTripPriceUiModel price;
  final List<ReviewTripOptionUiModel> options;
  final List<ReviewTripActionUiModel> actions;
  final String confirmButtonText;

  ReviewTripUiModel({
    required this.isIndividual,
    required this.date,
    required this.time,
    required this.route,
    required this.vehicle,
    required this.price,
    required this.options,
    required this.actions,
    required this.confirmButtonText,
  });

  String get formattedDateTime => '$date at $time';
}

class ReviewTripRouteUiModel {
  final String pickupLabel;
  final String pickupTime;
  final String pickupLocation;
  final String dropOffLabel;
  final String dropOffLocation;

  ReviewTripRouteUiModel({
    required this.pickupLabel,
    required this.pickupTime,
    required this.pickupLocation,
    required this.dropOffLabel,
    required this.dropOffLocation,
  });
}

class ReviewTripVehicleUiModel {
  final String name;
  final String imageUrl;
  final int passengerCapacity;
  final int luggageCapacity;

  ReviewTripVehicleUiModel({
    required this.name,
    required this.imageUrl,
    required this.passengerCapacity,
    required this.luggageCapacity,
  });
}

class ReviewTripPriceUiModel {
  final double amount;
  final String currency;
  final String label;
  final double? taxAmount;
  final bool promoApplied;

  ReviewTripPriceUiModel({
    required this.amount,
    required this.currency,
    required this.label,
    this.taxAmount,
    this.promoApplied = false,
  });

  static String _symbolFor(String code) {
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

  String get formattedPrice => '${_symbolFor(currency)}${amount.toStringAsFixed(2)}';

  bool get hasStrikethroughPrice => promoApplied;

  String? get formattedTaxAmount {
    if (taxAmount == null) return null;
    return 'VAT ${_symbolFor(currency)}${taxAmount!.toStringAsFixed(2)}';
  }

  bool get hasStrikethroughTax => promoApplied && taxAmount != null;
}

class ReviewTripOptionUiModel {
  final String iconName;
  final String title;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;
  /// When false, the option switch is disabled (e.g. Meet & Assist when flight not filled).
  final bool isSelectable;

  ReviewTripOptionUiModel({
    required this.iconName,
    required this.title,
    required this.isEnabled,
    required this.onChanged,
    this.isSelectable = true,
  });
}

class ReviewTripActionUiModel {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  ReviewTripActionUiModel({
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

class ReviewTripUiModelFactory {
  static ReviewTripUiModel getFakeData() {
    return ReviewTripUiModel(
      isIndividual: true,
      date: 'Mar 23,2025',
      time: '4:20 pm',
      route: ReviewTripRouteUiModel(
        pickupLabel: 'Pick up details',
        pickupTime: DateFormat('h:mm a').format(DateTime.now()),
        pickupLocation: 'Your current location',
        dropOffLabel: 'Drop off details',
        dropOffLocation: 'Alando Cafe, 32454 Marission street',
      ),
      vehicle: ReviewTripVehicleUiModel(
        name: 'Sedan',
        imageUrl:
            'https://media.architecturaldigest.com/photos/66a914f1a958d12e0cc94a8e/16:9/w_2240,c_limit/DSC_5903.jpg',
        passengerCapacity: 3,
        luggageCapacity: 2,
      ),
      price: ReviewTripPriceUiModel(
        amount: 85.00,
        currency: 'USD',
        label: 'Include',
      ),
      options: [
        ReviewTripOptionUiModel(
          iconName: 'profile',
          title: 'Meet with a Sign',
          isEnabled: false,
          onChanged: (value) {},
        ),
        ReviewTripOptionUiModel(
          iconName: 'pick-up',
          title: 'On Curb',
          isEnabled: false,
          onChanged: (value) {},
        ),
        ReviewTripOptionUiModel(
          iconName: 'wifi',
          title: 'WiFi',
          isEnabled: false,
          onChanged: (value) {},
        ),
      ],
      actions: [
        ReviewTripActionUiModel(title: 'Promo Code', onTap: () {}),
      ],
      confirmButtonText: 'Confirm Booking',
    );
  }
}
