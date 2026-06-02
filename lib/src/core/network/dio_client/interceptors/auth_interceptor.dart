import 'package:dio/dio.dart';

import '../../../utils/constants/app_const/app_const.dart';

/// Interceptor that automatically injects the Bearer token into request headers.
///
/// This interceptor reads the access token from [AppConst.accessToken]
/// and adds it to the `Authorization` header of every outgoing request.
///
/// Requests that should not include authentication can be excluded by using
/// the [withoutAuth] extension on [Options].
class AuthInterceptor extends Interceptor {
  /// Custom header key to skip authentication for specific requests.
  static const String skipAuthHeader = 'requiresAuth';

  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check if this request should skip authentication
    final requiresAuth = options.extra[skipAuthHeader] ?? true;

    if (requiresAuth && AppConst.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${AppConst.accessToken}';
    }

    // Remove the custom header from extras (not needed in actual request)
    options.extra.remove(skipAuthHeader);

    handler.next(options);
  }
}

/// Extension to add skipAuth option to RequestOptions.
extension AuthRequestOptionsExtension on RequestOptions {
  /// Sets whether this request requires authentication.
  ///
  /// Usage:
  /// ```dart
  /// dio.post('/login', options: Options()..skipAuth());
  /// ```
  void skipAuth() {
    extra[AuthInterceptor.skipAuthHeader] = false;
  }
}

/// Extension to add skipAuth option to Options.
extension AuthOptionsExtension on Options {
  /// Returns a new Options that skips authentication.
  ///
  /// Usage:
  /// ```dart
  /// dio.post('/login', options: Options().withoutAuth());
  /// ```
  Options withoutAuth() {
    final newExtra = Map<String, dynamic>.from(extra ?? {});
    newExtra[AuthInterceptor.skipAuthHeader] = false;
    return copyWith(extra: newExtra);
  }
}
