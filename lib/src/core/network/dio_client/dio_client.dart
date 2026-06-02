import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'exceptions/_exceptions.dart';
import 'interceptors/_interceptors.dart';
import 'result.dart';

/// Response parser function type.
typedef ResponseParser<T> = T Function(dynamic json);

/// Configuration options for [DioClient].
class DioClientConfig {
  /// Base URL for all requests.
  final String baseUrl;

  /// Connection timeout duration.
  final Duration connectTimeout;

  /// Receive timeout duration.
  final Duration receiveTimeout;

  /// Send timeout duration.
  final Duration sendTimeout;

  /// Default headers for all requests.
  final Map<String, String>? defaultHeaders;

  /// Whether to enable logging.
  final bool enableLogging;

  /// Log level for the logging interceptor.
  final LogLevel logLevel;

  /// Whether to enable retry on failed requests.
  final bool enableRetry;

  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Callback for re-authenticating (refreshing token).
  final Future<void> Function()? onReAuth;

  /// Callback when token refresh fails.
  final OnTokenRefreshFailedCallback? onTokenRefreshFailed;

  const DioClientConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.defaultHeaders,
    this.enableLogging = true,
    this.logLevel = LogLevel.body,
    this.enableRetry = true,
    this.maxRetries = 3,
    this.onReAuth,
    this.onTokenRefreshFailed,
  });
}

/// Production-ready Dio HTTP client with built-in interceptors and error handling.
///
/// Features:
/// - Automatic token injection and refresh
/// - Comprehensive error handling with typed exceptions
/// - Request retry with exponential backoff
/// - Production-safe logging
/// - Generic response parsing with Result type
///
/// Usage:
/// ```dart
/// final client = DioClient(
///   config: DioClientConfig(
///     baseUrl: 'https://api.example.com',
///     onReAuth: () async {
///       // Refresh token logic
///     },
///   ),
/// );
///
/// final result = await client.get<User>(
///   '/users/me',
///   parser: (json) => User.fromJson(json),
/// );
///
/// result.when(
///   success: (user) => print('User: ${user.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
class DioClient {
  /// The underlying Dio instance.
  late final Dio _dio;

  /// The configuration for this client.
  final DioClientConfig config;

  /// Creates a new [DioClient] with the given configuration.
  DioClient({required this.config}) {
    _dio = _createDio();
    _setupInterceptors();
  }

  /// Creates a new [DioClient] with a custom Dio instance.
  ///
  /// Useful for testing with mocked Dio.
  @visibleForTesting
  DioClient.withDio({required Dio dio, required this.config}) : _dio = dio;

  /// Access the underlying Dio instance for advanced use cases.
  Dio get dio => _dio;

  /// Creates and configures the Dio instance.
  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?config.defaultHeaders,
        },
        validateStatus: (status) =>
            status != null && status < 500 && status != 401,
      ),
    );

    return dio;
  }

  /// Sets up interceptors in the correct order.
  void _setupInterceptors() {
    // 1. Auth (add token to requests FIRST)
    _dio.interceptors.add(AuthInterceptor());

    // 2. Logging (after auth so we can see the Authorization header)
    if (config.enableLogging) {
      _dio.interceptors.add(LoggingInterceptor(logLevel: config.logLevel));
    }

    // 3. Retry (before error transformation)
    if (config.enableRetry) {
      _dio.interceptors.add(
        RetryInterceptor(dio: _dio, maxRetries: config.maxRetries),
      );
    }

    // 4. Token refresh (handles 401 and retries)
    if (config.onReAuth != null) {
      _dio.interceptors.add(
        TokenRefreshInterceptor(dio: _dio, onReAuth: config.onReAuth!),
      );
    }

    // 5. Error transformation (last to catch all errors)
    _dio.interceptors.add(ErrorInterceptor());
  }

  // ===========================================================================
  // HTTP Methods
  // ===========================================================================

  /// Performs a GET request.
  ///
  /// [endpoint] - The API endpoint (will be appended to baseUrl)
  /// [parser] - Function to parse the response JSON into type [T]
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional additional headers
  /// [options] - Optional Dio request options
  /// [body] - Optional request body (some APIs expect a body with GET)
  Future<Result<T, NetworkException>> get<T>({
    required String endpoint,
    required ResponseParser<T> parser,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    dynamic body,
  }) async {
    return _executeRequest(
      () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        data: body,
        options: _mergeOptions(options, headers),
      ),
      parser: parser,
    );
  }

  /// Performs a POST request.
  ///
  /// [endpoint] - The API endpoint
  /// [parser] - Function to parse the response JSON into type [T]
  /// [body] - Optional request body
  /// [queryParameters] - Optional query parameters
  /// [headers] - Optional additional headers
  /// [options] - Optional Dio request options
  Future<Result<T, NetworkException>> post<T>({
    required String endpoint,
    required ResponseParser<T> parser,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      ),
      parser: parser,
    );
  }

  /// Performs a PUT request.
  Future<Result<T, NetworkException>> put<T>({
    required String endpoint,
    required ResponseParser<T> parser,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.put(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      ),
      parser: parser,
    );
  }

  /// Performs a PATCH request.
  Future<Result<T, NetworkException>> patch<T>({
    required String endpoint,
    required ResponseParser<T> parser,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.patch(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      ),
      parser: parser,
    );
  }

  /// Performs a DELETE request.
  Future<Result<T, NetworkException>> delete<T>({
    required String endpoint,
    required ResponseParser<T> parser,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.delete(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      ),
      parser: parser,
    );
  }

  /// Performs a multipart file upload.
  ///
  /// [endpoint] - The API endpoint
  /// [parser] - Function to parse the response JSON into type [T]
  /// [files] - Map of field names to file paths
  /// [fields] - Optional additional form fields
  /// [onSendProgress] - Optional callback for upload progress
  /// [methodPatch] - If true, use PATCH instead of POST
  Future<Result<T, NetworkException>> upload<T>({
    required String endpoint,
    required ResponseParser<T> parser,
    required Map<String, String> files,
    Map<String, dynamic>? fields,
    void Function(int sent, int total)? onSendProgress,
    Map<String, String>? headers,
    bool methodPatch = false,
  }) async {
    try {
      final formData = FormData();

      // Add files
      for (final entry in files.entries) {
        formData.files.add(
          MapEntry(entry.key, await MultipartFile.fromFile(entry.value)),
        );
      }

      // Add fields
      fields?.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      final request = methodPatch ? _dio.patch : _dio.post;
      return _executeRequest(
        () => request(
          endpoint,
          data: formData,
          options: _mergeOptions(
            Options(contentType: 'multipart/form-data'),
            headers,
          ),
          onSendProgress: onSendProgress,
        ),
        parser: parser,
      );
    } catch (e, stackTrace) {
      return Failure(
        UnknownException(
          message: 'Failed to prepare upload: ${e.toString()}',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Performs a file download.
  ///
  /// [url] - The URL to download from
  /// [savePath] - Local path to save the file
  /// [onReceiveProgress] - Optional callback for download progress
  Future<Result<void, NetworkException>> download({
    required String url,
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
    Map<String, String>? headers,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: _mergeOptions(null, headers),
      );
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.toNetworkException());
    } catch (e, stackTrace) {
      return Failure(
        UnknownException(
          message: 'Download failed: ${e.toString()}',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // ===========================================================================
  // Helper Methods
  // ===========================================================================

  /// Executes a request and wraps the result in a [Result].
  Future<Result<T, NetworkException>> _executeRequest<T>(
    Future<Response<dynamic>> Function() request, {
    required ResponseParser<T> parser,
  }) async {
    try {
      final response = await request();

      // Check for error status codes that passed validateStatus
      if (response.statusCode != null && response.statusCode! >= 400) {
        return Failure(
          NetworkException.fromDioException(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          ),
        );
      }

      // Parse successful response
      final parsedData = parser(response.data);
      return Success(parsedData);
    } on DioException catch (e) {
      return Failure(e.toNetworkException());
    } catch (e, stackTrace) {
      return Failure(
        UnknownException(
          message: 'Unexpected error: ${e.toString()}',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Merges additional headers into Options.
  Options? _mergeOptions(Options? options, Map<String, String>? headers) {
    if (headers == null && options == null) return null;

    final mergedOptions = options ?? Options();
    if (headers != null) {
      mergedOptions.headers = {...?mergedOptions.headers, ...headers};
    }
    return mergedOptions;
  }

  /// Creates a request without authentication.
  ///
  /// Useful for login, registration, or public endpoints.
  Future<Result<T, NetworkException>> getWithoutAuth<T>({
    required String endpoint,
    required ResponseParser<T> parser,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return get(
      endpoint: endpoint,
      parser: parser,
      queryParameters: queryParameters,
      headers: headers,
      options: Options().withoutAuth(),
    );
  }

  /// Creates a POST request without authentication.
  Future<Result<T, NetworkException>> postWithoutAuth<T>({
    required String endpoint,
    required ResponseParser<T> parser,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return post(
      endpoint: endpoint,
      parser: parser,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      options: Options().withoutAuth(),
    );
  }
}
