import 'package:flutter/material.dart';

import 'package:avis_package/src/core/routes/app_router.dart';
import 'package:avis_package/src/core/routes/app_routes.dart';

/// Navigation for [avis_package] when embedded in a host app with its own routes.
///
/// Do **not** use [Navigator.pushNamed] with [AppRoutes] from the host app — the host
/// [MaterialApp] will not resolve package route names.
///
/// **From the host app**, open a package screen with:
/// ```dart
/// AvisNavigation.push(context, AppRoutes.servicePage);
/// ```
///
/// **Or** merge package routes into the host [MaterialApp]:
/// ```dart
/// onGenerateRoute: (settings) =>
///     AvisNavigation.onGenerateRoute(settings) ?? myHostRoutes(settings),
/// ```
class AvisNavigation {
  AvisNavigation._();

  /// Optional: assign to the host [MaterialApp.navigatorKey] so package code can
  /// navigate when no [BuildContext] is available.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'AvisNavigation');

  static BuildContext? get context => navigatorKey.currentContext;

  static const Set<String> _avisRoutes = {
    AppRoutes.splash,
    AppRoutes.navigatorHandler,
    AppRoutes.servicePage,
    AppRoutes.reviewTrip,
    AppRoutes.chat,
    AppRoutes.myTrips,
    AppRoutes.tripDetails,
    AppRoutes.addNewCard,
    AppRoutes.rideRequest,
    AppRoutes.map,
    AppRoutes.savedLocations,
    AppRoutes.addNewPlace,
    AppRoutes.locationPicker,
    AppRoutes.saveDetails,
  };

  static bool isAvisRoute(String? name) =>
      name != null && _avisRoutes.contains(name);

  /// Returns a package route for [settings], or null if not an [AppRoutes] name.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (!isAvisRoute(settings.name)) return null;
    return AppRouter.generateRoute(settings);
  }

  static Route<T> _route<T>(String routeName, {Object? arguments}) {
    return AppRouter.generateRoute(
      RouteSettings(name: routeName, arguments: arguments),
    ) as Route<T>;
  }

  static NavigatorState _navigator(
    BuildContext context, {
    bool rootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator);
  }

  /// Push a package screen onto the nearest (or root) navigator.
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool rootNavigator = false,
  }) {
    return _navigator(context, rootNavigator: rootNavigator).push<T>(
      _route<T>(routeName, arguments: arguments),
    );
  }

  /// Same as [push] but uses [navigatorKey] when [context] is unavailable.
  static Future<T?> pushGlobal<T>(
    String routeName, {
    Object? arguments,
  }) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      throw StateError(
        'AvisNavigation.navigatorKey is not attached to a Navigator. '
        'Set MaterialApp(navigatorKey: AvisNavigation.navigatorKey) or call push(context, ...).',
      );
    }
    return nav.push<T>(_route<T>(routeName, arguments: arguments));
  }

  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
    bool rootNavigator = false,
  }) {
    return _navigator(context, rootNavigator: rootNavigator)
        .pushReplacement<T, TO>(
      _route<T>(routeName, arguments: arguments),
      result: result,
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    required RoutePredicate predicate,
    bool rootNavigator = false,
  }) {
    return _navigator(context, rootNavigator: rootNavigator)
        .pushAndRemoveUntil<T>(
      _route<T>(routeName, arguments: arguments),
      predicate,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    _navigator(context).pop<T>(result);
  }
}
