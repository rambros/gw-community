# Deep Links Configuration Guide

## iOS Configuration

### 1. Update Info.plist

Add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>org.callofthetime.gw</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>gw</string>
    </array>
  </dict>
</array>

<!-- Universal Links (HTTPS) -->
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:gw.callofthetime.org</string>
</array>
```

### 2. Create apple-app-site-association file

Host this file at:
`https://gw.callofthetime.org/.well-known/apple-app-site-association`

```json
{
    "applinks": {
        "apps": [],
        "details": [
            {
                "appID": "TEAM_ID.org.callofthetime.gw",
                "paths": ["/invite", "/invite/*"]
            }
        ]
    }
}
```

## Android Configuration

### 1. Update AndroidManifest.xml

Add to `android/app/src/main/AndroidManifest.xml` inside `<activity>`:

```xml
<!-- Deep Links (Custom Scheme) -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="gw" />
</intent-filter>

<!-- App Links (HTTPS) -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="https"
    android:host="gw.callofthetime.org"
    android:pathPrefix="/invite" />
</intent-filter>
```

### 2. Create assetlinks.json file

Host this file at: `https://gw.callofthetime.org/.well-known/assetlinks.json`

```json
[{
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
        "namespace": "android_app",
        "package_name": "org.callofthetime.gw",
        "sha256_cert_fingerprints": [
            "YOUR_SHA256_FINGERPRINT_HERE"
        ]
    }
}]
```

To get SHA256 fingerprint:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## Flutter Code

### 1. Add dependencies to pubspec.yaml

```yaml
dependencies:
    uni_links: ^0.5.1
    app_links: ^3.4.5
```

### 2. Handle deep links in main.dart

```dart
import 'package:app_links/app_links.dart';

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // Handle link that opened the app
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path == '/invite') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        // Navigate to invite page
        GoRouter.of(context).go('/invite?token=$token');
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}
```

## Testing Deep Links

### iOS Simulator

```bash
xcrun simctl openurl booted "gw://invite?token=test123"
xcrun simctl openurl booted "https://gw.callofthetime.org/invite?token=test123"
```

### Android Emulator

```bash
adb shell am start -W -a android.intent.action.VIEW -d "gw://invite?token=test123"
adb shell am start -W -a android.intent.action.VIEW -d "https://gw.callofthetime.org/invite?token=test123"
```

## Web Fallback Page

Create a smart landing page that detects the platform and redirects accordingly.

See: `web/invite_redirect.html`
