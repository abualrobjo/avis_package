class AppConst {
  /// Pubspec [name] — use for [Image.asset], [BitmapDescriptor.asset], etc. in host apps.
  static const String packageName = 'avis_package';

  static String accessToken = '';
  static String lang = 'en';

  /// Default customer id when the user is not logged in; host may override via route `customerId`.
  static int fallbackCustomerId = 6756;

  /// `true` for test servers, `false` for live.
  static const bool isTestEnvironment = false;

  static const String _paymentLiveBaseUrl = 'https://chauffeurdriven.avis.eg/';
  static const String _paymentTestBaseUrl = 'http://94.249.88.254:1040/';

  static const String _apiLiveBaseUrl = 'https://avisbudget.fleetexpress.me/';
  static const String _apiTestBaseUrl = 'http://94.249.88.254:1045/';

  /// Chauffeur payment host base URL (test or live).
  static String get paymentHostBaseUrl =>
      isTestEnvironment ? _paymentTestBaseUrl : _paymentLiveBaseUrl;

  /// API host base URL (test or live).
  static String get apiBaseUrl =>
      isTestEnvironment ? _apiTestBaseUrl : _apiLiveBaseUrl;

  /// Chauffeur payment WebView entry URL (query params appended at call site).
  static String get paymentBaseUrl =>
      '${paymentHostBaseUrl}ChauffeurService/ChauffeurPayment';

  /// Chauffeur payment WebView closes with success when redirect hits this path (see PaymentScreen).
  static const String paymentRedirectSuccessPath = '/Home/PaymentSuccess';

  /// Chauffeur payment WebView closes with failure when redirect hits this path (see PaymentScreen).
  static const String paymentRedirectFailedPath = '/Home/PaymentFailed';
}
