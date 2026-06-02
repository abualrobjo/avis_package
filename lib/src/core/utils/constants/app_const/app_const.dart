class AppConst {
  static String accessToken = '';
  static String lang = 'en';

  /// Default customer id when the user is not logged in (saved places, trips, booking, etc.).
  static const int fallbackCustomerId = 6756;

  /// Chauffeur payment WebView closes with success when redirect hits this path (see PaymentScreen).
  static const String paymentRedirectSuccessPath = '/Home/PaymentSuccess';

  /// Chauffeur payment WebView closes with failure when redirect hits this path (see PaymentScreen).
  static const String paymentRedirectFailedPath = '/Home/PaymentFailed';
}
