import 'dart:async';

import 'package:dio/dio.dart';

import 'package:avis_package/src/core/_core.dart';

/// Callback type for refreshing tokens.
///
/// Should return a tuple of (accessToken, refreshToken) on success,
/// or throw an exception on failure.
typedef TokenRefreshCallback =
    Future<({String accessToken, String refreshToken, DateTime expiry})>
    Function(String refreshToken);

/// Callback type for handling token refresh failure (e.g., logging out user).
typedef OnTokenRefreshFailedCallback = void Function();

/// Interceptor that automatically refreshes expired access tokens.
///
/// This interceptor uses [QueuedInterceptor] to ensure that when multiple
/// requests fail with 401, only one token refresh is attempted, and all
/// queued requests are retried with the new token.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(TokenRefreshInterceptor(
///   dio: dio,
///   onRefresh: (refreshToken) async {
///     final response = await refreshApi.refresh(refreshToken);
///     return (
///       accessToken: response.accessToken,
///       refreshToken: response.refreshToken,
///       expiry: response.expiry,
///     );
///   },
///   onRefreshFailed: () {
///     // Navigate to login, clear user data, etc.
///   },
/// ));
/// ```

// ignore_for_file: unused_field

class TokenRefreshInterceptor extends QueuedInterceptor {
  /// The Dio instance used to retry failed requests.
  final Dio dio;

  /// Callback to perform the actual token refresh.
  final Future<void> Function() onReAuth;

  /// Whether a token refresh is currently in progress.
  bool _isRefreshing = false;

  /// Completer used to coordinate multiple concurrent refresh requests.
  Completer<void>? _refreshCompleter;

  TokenRefreshInterceptor({required this.dio, required this.onReAuth});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Check if this request was already a retry (prevent infinite loop)
    if (err.requestOptions.extra['isRetry'] == true) {
      return handler.next(err);
    }

    // Check if the filtered request requires authentication
    // If it doesn't, we shouldn't attempt to refresh or retry with auth
    final requiresAuth =
        err.requestOptions.extra[AuthInterceptor.skipAuthHeader] ?? true;
    if (!requiresAuth) {
      return handler.next(err);
    }

    try {
      // Wait for any ongoing refresh to complete
      if (_isRefreshing) {
        await _refreshCompleter?.future;
      } else {
        // Start a new refresh
        _isRefreshing = true;
        _refreshCompleter = Completer<void>();

        try {
          await onReAuth();
          _refreshCompleter?.complete();
        } catch (e) {
          _refreshCompleter?.completeError(e);
          _isRefreshing = false;
          _refreshCompleter = null;
          return handler.next(err);
        } finally {
          _isRefreshing = false;
          _refreshCompleter = null;
        }
      }

      // Retry the original request with the new token
      final retryOptions = err.requestOptions;
      retryOptions.extra['isRetry'] = true;

      if (AppConst.accessToken.isNotEmpty) {
        retryOptions.headers['Authorization'] =
            'Bearer ${AppConst.accessToken}';
      }

      final response = await dio.fetch(retryOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }
}

/// Extension to check if an error is due to an expired token.
extension TokenErrorExtension on NetworkException {
  /// Returns true if this exception indicates an expired/invalid token.
  bool get isTokenExpired => this is UnauthorizedException;
}
