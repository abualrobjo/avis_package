import 'package:dio/dio.dart';

import '../exceptions/_exceptions.dart';

/// Interceptor that transforms [DioException]s into typed [NetworkException]s.
///
/// This interceptor should be added LAST in the interceptor chain (after auth,
/// logging, etc.) to ensure all errors are properly transformed before being
/// returned to the caller.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(ErrorInterceptor());
/// ```
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if the error has already been transformed
    if (err.error is NetworkException) {
      handler.next(err);
      return;
    }

    // Transform DioException to NetworkException
    final networkException = NetworkException.fromDioException(err);

    // Wrap the NetworkException in a new DioException
    final wrappedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: networkException,
      stackTrace: err.stackTrace,
      message: networkException.message,
    );

    handler.next(wrappedError);
  }
}

/// Extension to easily extract NetworkException from DioException.
extension DioExceptionExtension on DioException {
  /// Returns the [NetworkException] if this error was transformed by [ErrorInterceptor].
  NetworkException? get networkException {
    final error = this.error;
    return error is NetworkException ? error : null;
  }

  /// Returns a typed [NetworkException], creating one if not already present.
  NetworkException toNetworkException() {
    final existing = networkException;
    if (existing != null) return existing;
    return NetworkException.fromDioException(this);
  }
}
