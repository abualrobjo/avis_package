/// Dio-based HTTP client with production features.
///
/// This library provides a complete networking solution with:
/// - Type-safe Result wrapper for error handling
/// - Comprehensive exception hierarchy
/// - Interceptors for auth, retry, logging, and error transformation
/// - Token refresh with request queuing
///
/// Usage:
/// ```dart
/// import 'package:avis_package/src/core/network/dio_client/_dio_client.dart';
///
/// final client = DioClient(
///   config: DioClientConfig(
///     baseUrl: ApiEndpoints.baseUrl,
///   ),
/// );
/// ```
library;

export 'api_endpoints.dart';
export 'dio_client.dart';
export 'exceptions/_exceptions.dart';
export 'interceptors/_interceptors.dart';
export 'result.dart';
