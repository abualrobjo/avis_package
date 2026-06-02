# Demo app setup (e.g. avis_demo)

When you use **avis_package** in a separate app (e.g. `com.example.avis_demo`), that **host app** must declare permissions and the Google Maps API key. The package cannot add these for you.

## Avoid crash before you add the API key

Until you add the API key to the manifest, set this in your app’s **main()** so the map screen shows a message instead of crashing:

```dart
import 'package:avis_package/avis_package.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AvisMapConfig.usePlaceholderInsteadOfMap = true;  // remove when key is in manifest
  runApp(MyApp());
}
```

After you add the key (see below), set `AvisMapConfig.usePlaceholderInsteadOfMap = false` or remove that line.

## 1. Android: `android/app/src/main/AndroidManifest.xml`

Add the following.

**Location permissions** (same level as `<application>`, not inside it):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**Google Maps API key** (inside `<application>`, before `<activity>`):

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_KEY_HERE"/>
```

Replace `YOUR_ACTUAL_KEY_HERE` with a real key from [Google Cloud Console](https://console.cloud.google.com/) (enable “Maps SDK for Android” for your project).

**Full example** (structure only):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

    <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_ACTUAL_KEY_HERE"/>

        <activity ...>
            ...
        </activity>
    </application>
</manifest>
```

Without these, you will see:
- “No permissions found in manifest” / “No location permissions are defined”
- “API key not found” and the app will crash when opening the map.

## 2. iOS: `ios/Runner/Info.plist`

Add location usage description:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location for the map and trip features.</string>
```

For Maps on iOS you also need to set the API key in `AppDelegate` (see [Google Maps iOS setup](https://developers.google.com/maps/documentation/ios-sdk/get-api-key)).

## 3. .env and GOOGLE_MAPS_API_KEY

- The **package** does not load `.env` itself. The **app** that uses the package must load it (e.g. in `main()`: `await dotenv.load()`).
- If your app has a `.env` with `GOOGLE_MAPS_API_KEY`, that is used only for **polyline routing** (route line on the map). The **Android** map still needs the key in `AndroidManifest.xml` as above; the Dart/env key is separate and only for the routing API.
- So: put the key in **AndroidManifest** (and iOS if needed) for the map to open; optionally use `.env` in the app for polylines.

## 4. "Authorization failure" on Android (map shows but key rejected)

If you see in logcat:

```text
E/Google Android Maps SDK: Authorization failure.  Please see ...
E/Google Android Maps SDK: Ensure that the "Maps SDK for Android" is enabled.
E/Google Android Maps SDK: Ensure that the following Android Key exists:
E/Google Android Maps SDK:   API Key: <your_key>
E/Google Android Maps SDK:   Android Application (<cert_fingerprint>;<package_name>): <sha1>;com.example.avis_demo
```

then the key is in the manifest but **Google Cloud is rejecting it**. Fix it in [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials:

1. **Enable the API**  
   Go to **APIs & Services → Library**, search for **Maps SDK for Android**, open it, and click **Enable** (for the same project that owns the API key).

2. **Allow your app for that key**  
   Go to **APIs & Services → Credentials**, open your **API key**, under **Application restrictions** choose **Android apps**, then add an entry:
   - **Package name**: your app’s package (e.g. `com.example.avis_demo`)
   - **SHA-1 certificate fingerprint**: the one from the error log (e.g. `34:BA:DC:13:48:E2:47:8D:7C:17:3E:24:FC:0E:35:62:62:78:4B:94`)

   For debug builds, use the debug SHA-1 (from `./gradlew signingReport` in the host app’s `android/` folder). For release, add the release SHA-1 as well.

3. **Save** and wait a short time; then run the app again.

If you use the same key for multiple apps (e.g. main app and demo app), add each package name + SHA-1 as a separate Android app restriction.
