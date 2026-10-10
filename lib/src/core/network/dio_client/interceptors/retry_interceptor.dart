import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

/// Interceptor that automatically retries failed requests with exponential backoff.
///
/// Features:
/// - Configurable retry count and delay
/// - Exponential backoff with jitter
/// - Only retries idempotent requests (GET, PUT, DELETE, HEAD, OPTIONS) by default
/// - Configurable status codes to retry on
/// - Network connectivity awareness
///
/// Usage:
/// ```dart
/// dio.interceptors.add(RetryInterceptor(
///   dio: dio,
///   maxRetries: 3,
///   retryDelays: [
///     Duration(seconds: 1),
///     Duration(seconds: 2),
///     Duration(seconds: 4),
///   ],
/// ));
/// ```
class RetryInterceptor extends Interceptor {
  /// The Dio instance used to retry requests.
  final Dio dio;

  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Delay before each retry attempt.
  ///
  /// If the list is shorter than [maxRetries], the last value is used for
  /// remaining retries.
  final List<Duration> retryDelays;

  /// HTTP methods that can be safely retried.
  final Set<String> retryableHttpMethods;

  /// HTTP status codes that should trigger a retry.
  final Set<int> retryableStatusCodes;

  /// Whether to retry on connection errors.
  final bool retryOnConnectionError;

  /// Whether to retry on timeout errors.
  final bool retryOnTimeout;

  /// Random generator for jitter.
  final Random _random = Random();

  /// Extra key to track retry count.
  static const String _retryCountKey = '_retryCount';

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
    this.retryableHttpMethods = const {
      'GET',
      'HEAD',
      'OPTIONS',
      'PUT',
      'DELETE',
    },
    this.retryableStatusCodes = const {
      408, // Request Timeout
      429, // Too Many Requests
      500, // Internal Server Error
      502, // Bad Gateway
      503, // Service Unavailable
      504, // Gateway Timeout
    },
    this.retryOnConnectionError = true,
    this.retryOnTimeout = true,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;

    // Get current retry count
    final retryCount = requestOptions.extra[_retryCountKey] as int? ?? 0;

    // Check if we should retry
    if (!_shouldRetry(err, retryCount)) {
      return handler.next(err);
    }

    // Calculate delay with jitter
    final delay = _getRetryDelay(retryCount);

    // Wait before retrying
    await Future.delayed(delay);

    // Update retry count
    requestOptions.extra[_retryCountKey] = retryCount + 1;

    try {
      // Retry the request
      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // If retry also fails, pass the new error
      return handler.next(e);
    }
  }

  /// Determines whether a request should be retried.
  bool _shouldRetry(DioException err, int retryCount) {
    // Check if we've exceeded max retries
    if (retryCount >= maxRetries) {
      return false;
    }

    // Check if the HTTP method is retryable
    if (!retryableHttpMethods.contains(
      err.requestOptions.method.toUpperCase(),
    )) {
      return false;
    }

    // Check error type
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return retryOnTimeout;

      case DioExceptionType.connectionError:
        return retryOnConnectionError;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        return statusCode != null && retryableStatusCodes.contains(statusCode);

      case DioExceptionType.unknown:
        // Retry on socket exceptions (network issues)
        return err.error is SocketException;

      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
    }
  }

  /// Calculates the retry delay with exponential backoff and jitter.
  Duration _getRetryDelay(int retryCount) {
    // Get base delay from the list
    final baseDelay = retryCount < retryDelays.length
        ? retryDelays[retryCount]
        : retryDelays.last;

    // Add jitter (±20%)
    final jitterFactor = 0.8 + (_random.nextDouble() * 0.4);
    final jitteredMillis = (baseDelay.inMilliseconds * jitterFactor).round();

    return Duration(milliseconds: jitteredMillis);
  }
}

/// Extension to mark requests as non-retryable.
extension RetryOptionsExtension on Options {
  /// Returns a new Options that won't be retried on failure.
  ///
  /// Usage:
  /// ```dart
  /// dio.post('/important-action', options: Options().noRetry());
  /// ```
  Options noRetry() {
    final newExtra = Map<String, dynamic>.from(extra ?? {});
    newExtra[RetryInterceptor._retryCountKey] = 999; // Exceed max retries
    return copyWith(extra: newExtra);
  }
}
