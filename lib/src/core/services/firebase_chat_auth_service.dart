import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Signs the customer into Firebase Auth with uid `customer_{id}`.
///
/// Requires a backend/Cloud Function that mints a Firebase custom token
/// (see `functions/` and `FIREBASE_CHAT_TOKEN_URL` in `.env`).
///
/// While Firestore rules are still open, a missing token URL is safe: chat
/// keeps working. Before activating secure rules, deploy the function and set
/// the env URL.
class FirebaseChatAuthService {
  FirebaseChatAuthService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static String customerUid(int customerId) => 'customer_$customerId';

  static String driverUid(int driverId) => 'driver_$driverId';

  /// Ensures FirebaseAuth.currentUser.uid == `customer_{customerId}`.
  ///
  /// No-ops (with a log) when `FIREBASE_CHAT_TOKEN_URL` is unset so the
  /// published app keeps working under open rules.
  Future<void> ensureCustomerSignedIn(int customerId) async {
    final uid = customerUid(customerId);
    final current = FirebaseAuth.instance.currentUser;
    if (current?.uid == uid) return;

    final tokenUrl = dotenv.env['FIREBASE_CHAT_TOKEN_URL']?.trim() ?? '';
    if (tokenUrl.isEmpty) {
      log(
        'FIREBASE_CHAT_TOKEN_URL not set — skipping Firebase Auth sign-in. '
        'OK while Firestore rules are open; required before secure rules.',
      );
      return;
    }

    if (current != null) {
      await FirebaseAuth.instance.signOut();
    }

    final secret = dotenv.env['FIREBASE_CHAT_TOKEN_SECRET']?.trim() ?? '';
    final response = await _dio.post<Map<String, dynamic>>(
      tokenUrl,
      data: <String, dynamic>{
        'role': 'customer',
        'customerId': customerId,
      },
      options: Options(
        headers: <String, dynamic>{
          if (secret.isNotEmpty) 'X-Chat-Token-Secret': secret,
        },
      ),
    );

    final token = response.data?['token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Firebase chat token response missing token');
    }

    await FirebaseAuth.instance.signInWithCustomToken(token);
    log('Firebase Auth signed in as $uid');
  }
}
