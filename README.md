# avis_package

Avis Flutter package: full lib (core + features) so you can use the project as a package from another application.

## Using the package from another app

### 1. Add dependency

```yaml
dependencies:
  avis_package:
    path: ../path/to/avis_package   # or git: url
```

### 2. Initialize and run

In your app’s `main.dart`:

1. Call `WidgetsFlutterBinding.ensureInitialized()`.
2. If you use **Chat**, call `await Firebase.initializeApp()` first.
3. Call `await init()` from the package (this registers Hive, Dio, services, providers).
4. Run your app with a `MaterialApp` that uses `onGenerateRoute: AppRouter.generateRoute` and `initialRoute: AppRoutes.splash` (or your preferred route).

Example:

```dart
import 'package:avis_package/avis_package.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // required for Chat
  await init();
  runApp(MyApp());
}

// In MyApp, use:
// onGenerateRoute: AppRouter.generateRoute,
// initialRoute: AppRoutes.splash,
```

### 3. Exports

- `package:avis_package/avis_package.dart` exports: core, features, `sl`, `init`, `AppRouter`, `AppRoutes`.

## Setup in your app

### 1. Google Maps API key (required for map screens)

**Android** – In your app’s `android/app/src/main/AndroidManifest.xml`, inside `<application>` add:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
```

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your key (or a build variable like `${GOOGLE_MAPS_API_KEY}` if you use one).

**iOS** – In `ios/Runner/AppDelegate.swift` (or `AppDelegate.m`) set the API key as per [Google Maps iOS setup](https://developers.google.com/maps/documentation/ios-sdk/get-api-key).

### 2. Location permissions

**Android** – In `AndroidManifest.xml` (outside `<application>`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS** – In `Info.plist` add `NSLocationWhenInUseUsageDescription` with your usage text.

### 3. Optional: polyline routing

For route polyline on the map, load `flutter_dotenv` in your app and put `GOOGLE_MAPS_API_KEY` in your `.env`. If not set, the map still works but the route line is not drawn.
