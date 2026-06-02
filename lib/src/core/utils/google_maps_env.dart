import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Google Maps / Places / Routes API key for REST calls.
///
/// Resolution order:
/// 1. [dotenv] `GOOGLE_MAPS_API_KEY` (host app must list `.env` in [pubspec] assets
///    and call [dotenv.load], or use [avis_package] [init] which loads `.env`).
/// 2. Compile-time `--dart-define=GOOGLE_MAPS_API_KEY=...` (no `.env` file needed).
String resolveGoogleMapsApiKey() {
  final fromDot = dotenv.env['GOOGLE_MAPS_API_KEY']?.trim();
  if (fromDot != null && fromDot.isNotEmpty) return fromDot;
  const fromDefine = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  final trimmed = fromDefine.trim();
  if (trimmed.isNotEmpty) return trimmed;
  return '';
}
