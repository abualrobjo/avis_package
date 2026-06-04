import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/_features.dart';
import 'package:avis_package/src/generated/locale_keys.g.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    RouteCustomerSession.applyFromRouteArguments(settings.arguments);

    switch (settings.name) {
      case AppRoutes.splash:
        return _slideRoute(const SplashPage(), settings);
      case AppRoutes.servicePage: {
        final args = settings.arguments is Map
            ? settings.arguments as Map<String, dynamic>
            : null;
        final showBackButton = args?['showBackButton'] == true;
        return _slideRoute(
          ChangeNotifierProvider(
            create: (_) => sl<LocalizationProvider>(),
            child: ServicesPage(showBackButton: showBackButton),
          ),
          settings,
        );
      }
      case AppRoutes.navigatorHandler:
        return _slideRoute(
          ChangeNotifierProvider(
            create: (_) => sl<LocalizationProvider>(),
            child: const NavigatorHandlerPage(),
          ),
          settings,
        );
      case AppRoutes.reviewTrip:
        return _slideRoute(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => sl<ReviewTripProvider>()),
              ChangeNotifierProvider(create: (_) => sl<AddNewCardProvider>()),
              ChangeNotifierProvider(create: (_) => sl<PaymentProvider>()),
            ],
            child: const ReviewTripPage(),
          ),
          settings,
        );
      case AppRoutes.chat:
        final args = settings.arguments is ChatPageArgs
            ? settings.arguments as ChatPageArgs
            : null;
        return _slideRoute(
          ChangeNotifierProvider(
            create: (_) => sl<ChatProvider>(),
            child: ChatPage(args: args),
          ),
          settings,
        );
      case AppRoutes.myTrips:
        return _slideRoute(
          ChangeNotifierProvider(
            create: (_) => sl<LocalizationProvider>(),
            child: ChangeNotifierProvider(
              create: (_) => sl<MyTripsProvider>(),
              child: const MyTripsPage(),
            ),
          ),
          settings,
        );
      case AppRoutes.tripDetails:
        final raw = settings.arguments;
        final int? tripId = raw is int
            ? raw
            : (raw is String ? int.tryParse(raw) : null);
        return _slideRoute(
          ChangeNotifierProvider(
            create: (_) => sl<LocalizationProvider>(),
            child: ChangeNotifierProvider(
              create: (_) => sl<MyTripsProvider>(),
              child: ChangeNotifierProvider(
                create: (_) => sl<PaymentProvider>(),
                child: TripDetailsPage(tripId: tripId ?? 0),
              ),
            ),
          ),
          settings,
        );
      case AppRoutes.addNewCard:
        {
          final provider = settings.arguments as AddNewCardProvider?;
          final page = provider != null
              ? ChangeNotifierProvider.value(
                  value: provider,
                  child: const AddNewCardPage(),
                )
              : ChangeNotifierProvider(
                  create: (_) => sl<AddNewCardProvider>(),
                  child: const AddNewCardPage(),
                );
          return _slideRoute(page, settings);
        }
      case AppRoutes.rideRequest:
        ReviewTripUiModel? tripModel;
        int? tripId;
        int? tripTypeId;
        bool fromMyTrips = false;
        bool cancellationBookLaterEnabled = false;
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          tripModel = args['tripModel'] as ReviewTripUiModel?;
          tripId = args['tripId'] as int?;
          tripTypeId = args['tripTypeId'] as int?;
          fromMyTrips = args['fromMyTrips'] == true;
          final rawCancel = args['cancellationBookLaterEnabled'];
          cancellationBookLaterEnabled = rawCancel == true ||
              rawCancel == 1 ||
              (rawCancel is String &&
                  rawCancel.toLowerCase() == 'true');
        } else if (args is ReviewTripUiModel) {
          tripModel = args;
          tripId = null;
        }
        return _slideRoute(
          RideRequestPage(
            tripModel: tripModel!,
            tripId: tripId,
            tripTypeId: tripTypeId,
            fromMyTrips: fromMyTrips,
            cancellationBookLaterEnabled: cancellationBookLaterEnabled,
          ),
          settings,
        );
      case AppRoutes.map:
        final tripId = settings.arguments as int?;
        return _slideRoute(
          ChangeNotifierProvider(
            create: (_) => sl<LocalizationProvider>(),
            child: MapPage(tripId: tripId ?? 0),
          ),
          settings,
        );
      case AppRoutes.savedLocations:
        return _slideRoute(
          ChangeNotifierProvider(
            create: (_) => sl<SavedLocationsProvider>(),
            child: const SavedLocationsPage(),
          ),
          settings,
        );
      case AppRoutes.addNewPlace:
        {
          final args = settings.arguments as Map<String, dynamic>?;
          final provider = args?['provider'] as SavedLocationsProvider?;
          final page = provider != null
              ? ChangeNotifierProvider.value(
                  value: provider,
                  child: const AddNewPlacePage(),
                )
              : ChangeNotifierProvider(
                  create: (_) => sl<SavedLocationsProvider>(),
                  child: const AddNewPlacePage(),
                );
          return _slideRoute(page, settings);
        }
      case AppRoutes.locationPicker:
        {
          final args = settings.arguments as Map<String, dynamic>?;
          final provider = args?['provider'] as SavedLocationsProvider?;
          final page = provider != null
              ? ChangeNotifierProvider.value(
                  value: provider,
                  child: const LocationPickerPage(),
                )
              : ChangeNotifierProvider(
                  create: (_) => sl<SavedLocationsProvider>(),
                  child: const LocationPickerPage(),
                );
          return _slideRoute(page, settings);
        }
      case AppRoutes.saveDetails:
        {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          final provider = args['provider'] as SavedLocationsProvider?;
          final detailsPage = SaveDetailsPage(
            address: args['address'] as String? ?? '',
            latitude: args['latitude'] as double? ?? 0.0,
            longitude: args['longitude'] as double? ?? 0.0,
            type: args['type'] as String? ?? 'custom',
          );
          final page = provider != null
              ? ChangeNotifierProvider.value(
                  value: provider,
                  child: detailsPage,
                )
              : ChangeNotifierProvider(
                  create: (_) => sl<SavedLocationsProvider>(),
                  child: detailsPage,
                );
          return _slideRoute(page, settings);
        }
      default:
        return MaterialPageRoute(
          builder: (_) => Theme(
            data: AppTheme.light,
            child: Scaffold(
              body: Center(
                child: Text(LocaleKeys.common_route_not_found.tr()),
              ),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? AppTheme.dark : AppTheme.light,
          child: page,
        );
      },
      transitionsBuilder: (_, animation, _, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    );
  }
}
