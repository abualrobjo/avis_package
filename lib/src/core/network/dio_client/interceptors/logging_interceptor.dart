import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Log level for the logging interceptor.
enum LogLevel {
  /// No logging.
  none,

  /// Log only errors.
  error,

  /// Log basic request/response info.
  basic,

  /// Log headers.
  headers,

  /// Log everything including body.
  body,
}

/// Production-safe logging interceptor with configurable log levels.
///
/// Features:
/// - Configurable log levels (none, error, basic, headers, body)
/// - Automatic redaction of sensitive headers (Authorization, Cookie, etc.)
/// - Pretty-printed JSON bodies
/// - Request timing
/// - Debug-only logging by default
///
/// Usage:
/// ```dart
/// dio.interceptors.add(LoggingInterceptor(
///   logLevel: kDebugMode ? LogLevel.body : LogLevel.error,
/// ));
/// ```
class LoggingInterceptor extends Interceptor {
  /// The log level to use.
  final LogLevel logLevel;

  /// Whether to log in release mode.
  final bool logInRelease;

  /// Headers that should be redacted in logs.
  final Set<String> sensitiveHeaders;

  /// Maximum body length to log (to prevent memory issues with large responses).
  final int maxBodyLength;

  /// Request start times for calculating duration.
  final Map<int, DateTime> _requestTimes = {};

  LoggingInterceptor({
    this.logLevel = LogLevel.body,
    this.logInRelease = false,
    this.sensitiveHeaders = const {
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
      'x-auth-token',
    },
    this.maxBodyLength = 10000,
  });

  bool get _shouldLog {
    if (logLevel == LogLevel.none) return false;
    if (logInRelease) return true;
    return kDebugMode;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldLog) {
      _requestTimes[options.hashCode] = DateTime.now();
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_shouldLog) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldLog || logLevel == LogLevel.error) {
      _logError(err);
    }
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln(
      '╔══════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ 🌐 REQUEST');
    buffer.writeln(
      '╠══════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ ${options.method.toUpperCase()} ${options.uri}');

    if (logLevel.index >= LogLevel.headers.index) {
      buffer.writeln('║');
      buffer.writeln('║ Headers:');
      _formatHeaders(options.headers, buffer);
    }

    if (logLevel == LogLevel.body && options.data != null) {
      buffer.writeln('║');
      buffer.writeln('║ Body:');
      _formatBody(options.data, buffer);
    }

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════',
    );

    _log(buffer.toString());
  }

  void _logResponse(Response response) {
    final requestTime = _requestTimes.remove(response.requestOptions.hashCode);
    final duration = requestTime != null
        ? DateTime.now().difference(requestTime).inMilliseconds
        : null;

    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln(
      '╔══════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ ✅ RESPONSE');
    buffer.writeln(
      '╠══════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ ${response.statusCode} ${response.statusMessage}');
    buffer.writeln(
      '║ ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}',
    );
    if (duration != null) {
      buffer.writeln('║ ⏱️ ${duration}ms');
    }

    if (logLevel.index >= LogLevel.headers.index) {
      buffer.writeln('║');
      buffer.writeln('║ Headers:');
      _formatHeaders(response.headers.map, buffer);
    }

    if (logLevel == LogLevel.body && response.data != null) {
      buffer.writeln('║');
      buffer.writeln('║ Body:');
      _formatBody(response.data, buffer);
    }

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════',
    );

    _log(buffer.toString());
  }

  void _logError(DioException error) {
    final requestTime = _requestTimes.remove(error.requestOptions.hashCode);
    final duration = requestTime != null
        ? DateTime.now().difference(requestTime).inMilliseconds
        : null;

    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln(
      '╔══════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ ❌ ERROR');
    buffer.writeln(
      '╠══════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ ${error.type.name}');
    buffer.writeln(
      '║ ${error.requestOptions.method.toUpperCase()} ${error.requestOptions.uri}',
    );
    if (duration != null) {
      buffer.writeln('║ ⏱️ ${duration}ms');
    }

    if (error.response != null) {
      buffer.writeln('║');
      buffer.writeln(
        '║ Status: ${error.response?.statusCode} ${error.response?.statusMessage}',
      );

      if (logLevel == LogLevel.body && error.response?.data != null) {
        buffer.writeln('║');
        buffer.writeln('║ Response Body:');
        _formatBody(error.response?.data, buffer);
      }
    }

    buffer.writeln('║');
    buffer.writeln('║ Message: ${error.message}');

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════',
    );

    _log(buffer.toString(), isError: true);
  }

  void _formatHeaders(Map<String, dynamic> headers, StringBuffer buffer) {
    headers.forEach((key, value) {
      final displayValue = sensitiveHeaders.contains(key.toLowerCase())
          ? '[REDACTED]'
          : value;
      buffer.writeln('║   $key: $displayValue');
    });
  }

  void _formatBody(dynamic body, StringBuffer buffer) {
    try {
      String bodyString;

      if (body is Map || body is List) {
        bodyString = const JsonEncoder.withIndent('  ').convert(body);
      } else if (body is FormData) {
        final fields = body.fields
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        final files = body.files
            .map((e) => '${e.key}: ${e.value.filename}')
            .join(', ');
        bodyString = 'FormData(fields: {$fields}, files: {$files})';
      } else {
        bodyString = body.toString();
      }

      // Truncate if too long
      if (bodyString.length > maxBodyLength) {
        bodyString = '${bodyString.substring(0, maxBodyLength)}...[TRUNCATED]';
      }

      // Add prefix to each line
      final lines = bodyString.split('\n');
      for (final line in lines) {
        buffer.writeln('║   $line');
      }
    } catch (e) {
      buffer.writeln('║   [Unable to format body: $e]');
    }
  }

  void _log(String message, {bool isError = false}) {
    if (kDebugMode) {
      developer.log(message, name: 'DioClient', level: isError ? 1000 : 0);
    } else if (logInRelease) {
      // In release mode, use print (consider using a proper logging library)
      // ignore: avoid_print
      print(message);
    }
  }
}
