// Avis package: full core and features for use from another application.
// Host app: call init() after WidgetsFlutterBinding.ensureInitialized() and
// Firebase.initializeApp() (if using Chat). init() loads `.env` from the host
// app's assets when listed in the host pubspec (same as acs_customer: `- .env`).
// Alternatively pass the key at build time: `--dart-define=GOOGLE_MAPS_API_KEY=...`.
//
// Navigation from the host: use [AvisNavigation.push], not [Navigator.pushNamed]
// with [AppRoutes] unless you merge [AvisNavigation.onGenerateRoute] into the host
// [MaterialApp].
//
// Package assets (icons, map markers, map styles) are loaded with
// `package: avis_package` automatically; no need to copy them into the host pubspec.

export 'src/core/_core.dart';
export 'src/features/_features.dart';
export 'src/core/services/di_service.dart' show sl, init;
export 'src/core/routes/app_router.dart';
export 'src/core/routes/app_routes.dart';
export 'src/core/routes/avis_navigation.dart';
