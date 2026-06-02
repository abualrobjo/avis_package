import 'package:dio/dio.dart';

import 'package:avis_package/src/core/_core.dart';

/// Abstract interface for app-level authentication operations.
abstract class AppAuthService {
  /// Fetches the initial OAuth token required for API access.
  ///
  /// Returns the access token string if successful.
  /// Throws on network or parsing errors.
  Future<String> fetchToken();
}

/// Implementation of [AppAuthService] using [DioClient].
class AppAuthServiceImpl implements AppAuthService {
  final DioClient _dioClient;
  final AuthLocalService _authLocalService;

  AppAuthServiceImpl(this._dioClient, this._authLocalService);

  @override
  Future<String> fetchToken() async {
    final result = await _dioClient.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.token,
      parser: (json) => json as Map<String, dynamic>,
      body: {'grant_type': 'password', 'username': 'web', 'password': 'web'},
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      options: Options().withoutAuth(),
    );

    return result.when(
      success: (data) {
        final token = data['access_token'] as String? ?? '';
        if (token.isNotEmpty) {
          AppConst.accessToken = token;
          _authLocalService.saveToken(token);
        }
        return token;
      },
      failure: (error) => throw error,
    );
  }
}
