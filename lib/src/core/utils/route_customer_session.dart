import 'package:avis_package/src/core/services/app_auth/auth_local_service.dart';
import 'package:avis_package/src/core/services/di_service.dart';
import 'package:avis_package/src/core/utils/constants/app_const/app_const.dart';

/// Applies `customerId` from host route arguments so existing code that uses
/// `AuthLocalService.getUserId() ?? AppConst.fallbackCustomerId` works unchanged.
class RouteCustomerSession {
  RouteCustomerSession._();

  static int? parseCustomerId(Object? arguments) {
    if (arguments is Map<String, dynamic>) {
      return _parseValue(arguments['customerId']);
    }
    if (arguments is Map) {
      return _parseValue(arguments['customerId']);
    }
    return null;
  }

  static int? _parseValue(Object? value) {
    if (value is int && value > 0) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  /// Call from [AppRouter.generateRoute] (or host `onGenerateRoute`) before building the page.
  static void applyFromRouteArguments(Object? arguments) {
    final id = parseCustomerId(arguments);
    if (id == null) return;

    AppConst.fallbackCustomerId = id;
    sl<AuthLocalService>().saveUserId(id);
  }
}
