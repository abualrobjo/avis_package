/// Holds the customer id passed from the host app (home page) for the current session.
class RouteCustomerSession {
  RouteCustomerSession._();

  static int? _routeCustomerId;

  /// Customer id from the latest route navigation (not persisted storage).
  static int? get currentCustomerId => _routeCustomerId;

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
    _routeCustomerId = id;
  }
}
