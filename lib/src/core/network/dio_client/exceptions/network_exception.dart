import 'dart:io';

import 'package:dio/dio.dart';

/// Base sealed class for all network-related exceptions.
///
/// Provides a unified way to handle different types of network errors
/// with meaningful messages and optional status codes.
sealed class NetworkException implements Exception {
  /// Human-readable error message.
  final String message;

  /// HTTP status code if applicable.
  final int? statusCode;

  /// The original error that caused this exception.
  final dynamic originalError;

  /// Stack trace from the original error.
  final StackTrace? stackTrace;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  /// Factory constructor to create the appropriate [NetworkException]
  /// subclass from a [DioException].
  factory NetworkException.fromDioException(DioException dioException) {
    final response = dioException.response;
    final statusCode = response?.statusCode;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message:
              'Connection timed out. Please check your internet connection.',
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case DioExceptionType.connectionError:
        if (dioException.error is SocketException) {
          return NoInternetException(
            message:
                'No internet connection. Please check your network settings.',
            originalError: dioException,
            stackTrace: dioException.stackTrace,
          );
        }
        return ConnectionException(
          message: 'Failed to connect to server. Please try again.',
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case DioExceptionType.badCertificate:
        return CertificateException(
          message: 'SSL certificate verification failed.',
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case DioExceptionType.badResponse:
        return _createFromStatusCode(
          statusCode: statusCode,
          response: response,
          dioException: dioException,
        );

      case DioExceptionType.cancel:
        return RequestCancelledException(
          message: 'Request was cancelled.',
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case DioExceptionType.unknown:
        if (dioException.error is SocketException) {
          return NoInternetException(
            message:
                'No internet connection. Please check your network settings.',
            originalError: dioException,
            stackTrace: dioException.stackTrace,
          );
        }
        return UnknownException(
          message: 'An unexpected error occurred. Please try again.',
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );
    }
  }

  /// Creates the appropriate exception based on HTTP status code.
  static NetworkException _createFromStatusCode({
    required int? statusCode,
    required Response? response,
    required DioException dioException,
  }) {
    final errorMessage = _extractErrorMessage(response);

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: errorMessage ?? 'Invalid request. Please check your input.',
          statusCode: statusCode,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
          validationErrors: _extractValidationErrors(response),
        );

      case 401:
        return UnauthorizedException(
          message:
              errorMessage ?? 'Authentication required. Please log in again.',
          statusCode: statusCode,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 403:
        return ForbiddenException(
          message: errorMessage ?? 'Access denied. You don\'t have permission.',
          statusCode: statusCode,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 404:
        return NotFoundException(
          message: errorMessage ?? 'Resource not found.',
          statusCode: statusCode,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 409:
        return ConflictException(
          message: errorMessage ?? 'Request conflicts with current state.',
          statusCode: statusCode,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      case 422:
        return UnprocessableEntityException(
          message: errorMessage ?? 'Unable to process request.',
          statusCode: statusCode,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
          validationErrors: _extractValidationErrors(response),
        );

      case 429:
        return TooManyRequestsException(
          message:
              errorMessage ?? 'Too many requests. Please wait and try again.',
          statusCode: statusCode,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
          retryAfter: _extractRetryAfter(response),
        );

      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: errorMessage ?? 'Server error. Please try again later.',
          statusCode: statusCode,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );

      default:
        return UnknownException(
          message: errorMessage ?? 'An unexpected error occurred.',
          statusCode: statusCode,
          originalError: dioException,
          stackTrace: dioException.stackTrace,
        );
    }
  }

  /// Attempts to extract an error message from the response body.
  static String? _extractErrorMessage(Response? response) {
    if (response?.data == null) return null;

    final data = response!.data;
    if (data is Map<String, dynamic>) {
      // Try common error message field names
      return data['message'] as String? ??
          data['error'] as String? ??
          data['errorMessage'] as String? ??
          data['error_description'] as String?;
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }

  /// Attempts to extract validation errors from the response body.
  static Map<String, List<String>>? _extractValidationErrors(
    Response? response,
  ) {
    if (response?.data == null) return null;

    final data = response!.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'] ?? data['validationErrors'];
      if (errors is Map<String, dynamic>) {
        return errors.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.cast<String>());
          }
          return MapEntry(key, [value.toString()]);
        });
      }
    }

    return null;
  }

  /// Attempts to extract retry-after header value.
  static Duration? _extractRetryAfter(Response? response) {
    final retryAfter = response?.headers.value('retry-after');
    if (retryAfter != null) {
      final seconds = int.tryParse(retryAfter);
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }
    return null;
  }

  @override
  String toString() => '$runtimeType: $message (statusCode: $statusCode)';
}

// ============================================================================
// Connection Exceptions
// ============================================================================

/// Exception thrown when there is no internet connection.
final class NoInternetException extends NetworkException {
  const NoInternetException({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(statusCode: null);
}

/// Exception thrown when a connection to the server fails.
final class ConnectionException extends NetworkException {
  const ConnectionException({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(statusCode: null);
}

/// Exception thrown when a request times out.
final class TimeoutException extends NetworkException {
  const TimeoutException({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(statusCode: null);
}

/// Exception thrown when SSL certificate verification fails.
final class CertificateException extends NetworkException {
  const CertificateException({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(statusCode: null);
}

/// Exception thrown when a request is cancelled.
final class RequestCancelledException extends NetworkException {
  const RequestCancelledException({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(statusCode: null);
}

// ============================================================================
// Client Exceptions (4xx)
// ============================================================================

/// Exception thrown for 400 Bad Request errors.
final class BadRequestException extends NetworkException {
  /// Field-specific validation errors, if available.
  final Map<String, List<String>>? validationErrors;

  const BadRequestException({
    required super.message,
    super.statusCode = 400,
    super.originalError,
    super.stackTrace,
    this.validationErrors,
  });
}

/// Exception thrown for 401 Unauthorized errors.
final class UnauthorizedException extends NetworkException {
  const UnauthorizedException({
    required super.message,
    super.statusCode = 401,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown for 403 Forbidden errors.
final class ForbiddenException extends NetworkException {
  const ForbiddenException({
    required super.message,
    super.statusCode = 403,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown for 404 Not Found errors.
final class NotFoundException extends NetworkException {
  const NotFoundException({
    required super.message,
    super.statusCode = 404,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown for 409 Conflict errors.
final class ConflictException extends NetworkException {
  const ConflictException({
    required super.message,
    super.statusCode = 409,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown for 422 Unprocessable Entity errors.
final class UnprocessableEntityException extends NetworkException {
  /// Field-specific validation errors, if available.
  final Map<String, List<String>>? validationErrors;

  const UnprocessableEntityException({
    required super.message,
    super.statusCode = 422,
    super.originalError,
    super.stackTrace,
    this.validationErrors,
  });
}

/// Exception thrown for 429 Too Many Requests errors.
final class TooManyRequestsException extends NetworkException {
  /// How long to wait before retrying, if provided by server.
  final Duration? retryAfter;

  const TooManyRequestsException({
    required super.message,
    super.statusCode = 429,
    super.originalError,
    super.stackTrace,
    this.retryAfter,
  });
}

// ============================================================================
// Server Exceptions (5xx)
// ============================================================================

/// Exception thrown for 5xx server errors.
final class ServerException extends NetworkException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });
}

// ============================================================================
// Unknown Exceptions
// ============================================================================

/// Exception thrown for unexpected/unknown errors.
final class UnknownException extends NetworkException {
  const UnknownException({
    required super.message,
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });
}
