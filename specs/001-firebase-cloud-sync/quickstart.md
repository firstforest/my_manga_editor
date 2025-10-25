# Quickstart: Firebase Cloud Sync Setup

**Feature**: 001-firebase-cloud-sync
**Date**: 2025-10-19
**Purpose**: Step-by-step guide to configure Firebase for My Manga Editor

## Prerequisites

- Flutter 3.32.4+ installed
- Google Cloud Platform account (free tier sufficient)
- macOS/Linux terminal or Windows PowerShell
- Git repository with My Manga Editor codebase

---

## Part 1: Firebase Project Setup

### Step 1.1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `my-manga-editor` (or your preference)
4. **Disable Google Analytics** (optional, can enable later)
5. Click "Create project"

### Step 1.2: Enable Authentication

1. In Firebase Console, navigate to **Build** → **Authentication**
2. Click "Get started"
3. Navigate to **Sign-in method** tab
4. Click **Google** provider
5. Toggle "Enable"
6. Set support email (your email)
7. Click "Save"

### Step 1.3: Create Firestore Database

1. In Firebase Console, navigate to **Build** → **Firestore Database**
2. Click "Create database"
3. Select **Start in production mode** (we'll add custom rules)
4. Choose Firestore location:
   - **Recommended**: `asia-northeast1` (Tokyo) for Japanese users
   - **Alternative**: `us-central1` (Iowa) for global access
5. Click "Enable"

### Step 1.4: Configure Firestore Security Rules

1. In Firestore Database, navigate to **Rules** tab
2. Replace default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User-scoped manga collections
    match /users/{userId}/mangas/{mangaId} {
      // Only authenticated users can access their own mangas
      allow read, write: if request.auth != null &&
                            request.auth.uid == userId;

      // Validation functions
      function isValidManga() {
        let data = request.resource.data;
        return data.keys().hasAll(['userId', 'name', 'startPageDirection', 'ideaMemo', 'createdAt', 'updatedAt']) &&
               data.userId is string &&
               data.name is string &&
               data.name.size() >= 1 &&
               data.name.size() <= 200 &&
               data.startPageDirection in ['left', 'right'] &&
               data.ideaMemo is map &&
               data.createdAt is timestamp &&
               data.updatedAt is timestamp;
      }

      // Create validation
      allow create: if isValidManga() &&
                       request.resource.data.userId == request.auth.uid;

      // Update validation
      allow update: if request.resource.data.userId == resource.data.userId;

      // Subcollections inherit parent rules
      match /pages/{pageId} {
        allow read, write: if request.auth != null &&
                              request.auth.uid == userId;

        function isValidPage() {
          let data = request.resource.data;
          return data.keys().hasAll(['pageIndex', 'memoDelta', 'stageDirectionDelta', 'dialoguesDelta', 'createdAt', 'updatedAt']) &&
                 data.pageIndex is int &&
                 data.pageIndex >= 0 &&
                 data.memoDelta is map &&
                 data.stageDirectionDelta is map &&
                 data.dialoguesDelta is map;
        }

        allow create: if isValidPage();
      }
    }
  }
}
```

3. Click "Publish"

---

## Part 2: Google Cloud Console Setup

### Step 2.1: Configure OAuth Consent Screen

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project (same name)
3. Navigate to **APIs & Services** → **OAuth consent screen**
4. Select **External** user type
5. Click "Create"
6. Fill required fields:
   - **App name**: "My Manga Editor"
   - **User support email**: your email
   - **Developer contact**: your email
7. Click "Save and Continue"
8. **Scopes**: Skip (default scopes sufficient)
9. **Test users** (optional): Add your email for testing
10. Click "Save and Continue" → "Back to Dashboard"

### Step 2.2: Create OAuth 2.0 Client IDs

#### Web Application Client

1. Navigate to **Credentials** tab
2. Click "Create Credentials" → "OAuth client ID"
3. Application type: **Web application**
4. Name: "My Manga Editor - Web"
5. **Authorized JavaScript origins**:
   - `http://localhost:5000` (for development)
   - `https://your-domain.com` (for production, add later)
6. **Authorized redirect URIs**:
   - `http://localhost:5000/__/auth/handler` (for development)
7. Click "Create"
8. **Save Client ID** (needed later)

#### iOS Application Client

1. Create Credentials → OAuth client ID
2. Application type: **iOS**
3. Name: "My Manga Editor - iOS"
4. **Bundle ID**: `com.yourcompany.mymangaeditor` (match your iOS app)
5. **App Store ID**: Leave blank (for development)
6. Click "Create"

#### Android Application Client (Debug)

1. Get debug SHA-1 certificate fingerprint:
   ```bash
   # macOS/Linux
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

   # Windows
   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

2. Copy the SHA-1 fingerprint (e.g., `A1:B2:C3:...`)

3. Create Credentials → OAuth client ID
4. Application type: **Android**
5. Name: "My Manga Editor - Android (Debug)"
6. **Package name**: `com.yourcompany.mymangaeditor`
7. **SHA-1 certificate fingerprint**: Paste debug fingerprint
8. Click "Create"

#### Android Application Client (Release)

Repeat above steps with release keystore SHA-1:
```bash
keytool -list -v -keystore /path/to/release.keystore -alias release
```

---

## Part 3: Flutter Firebase CLI Setup

### Step 3.1: Install FlutterFire CLI

```bash
# Activate FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

### Step 3.2: Configure Firebase for Flutter

```bash
# Navigate to project root
cd /path/to/my_manga_editor

# Login to Firebase (opens browser)
firebase login

# Configure Firebase for all platforms
flutterfire configure --project=my-manga-editor

# Select platforms:
# [x] android
# [x] ios
# [x] macos
# [x] web
# [ ] windows (skip - not production-ready)
# [ ] linux (skip - not production-ready)
```

**This generates**:
- `lib/firebase_options.dart` (platform-specific Firebase config)
- Updates platform-specific config files:
  - Android: `android/app/google-services.json`
  - iOS: `ios/Runner/GoogleService-Info.plist`
  - macOS: `macos/Runner/GoogleService-Info.plist`

---

## Part 4: Flutter Dependencies

### Step 4.1: Add Firebase Packages

Edit `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Existing dependencies...
  cupertino_icons: ^1.0.8
  flutter_quill: ^11.4.0
  # ... (keep all existing)

  # NEW: Firebase packages
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.3
  google_sign_in: ^6.2.2
  cloud_firestore: ^5.5.0

dev_dependencies:
  # ... (existing dev dependencies)
```

Install dependencies:

```bash
flutter pub get
```

---

## Part 5: Platform-Specific Configuration

### Step 5.1: iOS Configuration

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.1234567890-abcdefg</string>
    </array>
  </dict>
</array>
```

**To find REVERSED_CLIENT_ID**:
1. Open `ios/Runner/GoogleService-Info.plist`
2. Look for `<key>REVERSED_CLIENT_ID</key>`
3. Copy the `<string>` value below it

### Step 5.2: Android Configuration

Edit `android/app/build.gradle`:

```gradle
android {
    // ... existing config

    defaultConfig {
        applicationId "com.yourcompany.mymangaeditor" // Match OAuth client package name
        minSdkVersion 21  // Firebase Auth requires SDK 21+
        targetSdkVersion flutter.targetSdkVersion
        // ... rest of config
    }
}

dependencies {
    // ... existing dependencies
    implementation platform('com.google.firebase:firebase-bom:33.0.0')
}
```

Verify `android/app/google-services.json` exists (auto-generated by FlutterFire CLI).

### Step 5.3: macOS Configuration

Edit `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
<key>keychain-access-groups</key>
<array>
  <string>$(AppIdentifierPrefix)com.yourcompany.mymangaeditor</string>
</array>
```

### Step 5.4: Web Configuration

Edit `web/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <!-- ... existing head content ... -->
</head>
<body>
  <!-- Add this BEFORE flutter.js script -->
  <script type="module">
    // Import the functions you need from the SDKs you need
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js';
    // TODO: Add SDKs for Firebase products that you want to use
    // https://firebase.google.com/docs/web/setup#available-libraries

    // Your web app's Firebase configuration (from firebase_options.dart)
    const firebaseConfig = {
      apiKey: "AIza...",
      authDomain: "my-manga-editor.firebaseapp.com",
      projectId: "my-manga-editor",
      storageBucket: "my-manga-editor.appspot.com",
      messagingSenderId: "123456789",
      appId: "1:123456789:web:abc123"
    };

    // Initialize Firebase
    const app = initializeApp(firebaseConfig);
  </script>

  <!-- Existing flutter.js script -->
  <script src="flutter.js" defer></script>
</body>
</html>
```

**Get Firebase config**:
1. Firebase Console → Project Settings → General
2. Scroll to "Your apps" → Web app
3. Copy config object

---

## Part 6: Initialize Firebase in Flutter

### Step 6.1: Update main.dart

Edit `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generated by FlutterFire CLI

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Step 6.2: Verify Firebase Initialization

Create a test file `lib/test_firebase.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void testFirebase() {
  // Test Firebase Auth
  final auth = FirebaseAuth.instance;
  print('Firebase Auth initialized: ${auth != null}');

  // Test Firestore
  final firestore = FirebaseFirestore.instance;
  print('Firestore initialized: ${firestore != null}');

  // Check auth state
  auth.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is signed out');
    } else {
      print('User is signed in: ${user.email}');
    }
  });
}
```

Run app:

```bash
flutter run -d macos  # or android/ios/chrome
```

Check console for:
```
Firebase Auth initialized: true
Firestore initialized: true
User is signed out
```

---

## Part 7: Firestore Offline Persistence

### Step 7.1: Enable Offline Persistence

Create `lib/service/firebase/firebase_config.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> configureFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // Configure offline persistence
  if (kIsWeb) {
    // Web requires explicit enabling
    await firestore.enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    );
  } else {
    // Mobile/Desktop: already enabled by default, configure cache size
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Or specific limit
    );
  }
}
```

Update `main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Firestore
  await configureFirestore();

  runApp(ProviderScope(child: MyApp()));
}
```

---

## Part 8: Testing Setup

### Step 8.1: Test Google Sign-In

Create `lib/test_auth.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<User?> testGoogleSignIn() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Trigger sign-in flow
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  if (googleUser == null) {
    print('Sign-in aborted');
    return null;
  }

  // Obtain auth details
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Sign in to Firebase
  final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  print('Signed in: ${userCredential.user?.email}');

  return userCredential.user;
}

Future<void> testSignOut() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
  print('Signed out');
}
```

### Step 8.2: Test Firestore Read/Write

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirestoreWrite() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('Not signed in');
    return;
  }

  final mangasRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('mangas');

  // Write test data
  final docRef = await mangasRef.add({
    'userId': user.uid,
    'name': 'Test Manga',
    'startPageDirection': 'left',
    'ideaMemo': {'ops': []},
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  print('Created manga: ${docRef.id}');

  // Read back
  final snapshot = await docRef.get();
  print('Read manga: ${snapshot.data()}');
}
```

---

## Part 9: Environment Variables (Optional)

For API keys and sensitive config, use environment variables:

### Step 9.1: Create .env file

Create `.env` (add to `.gitignore`):

```
FIREBASE_API_KEY=AIza...
FIREBASE_PROJECT_ID=my-manga-editor
FIREBASE_AUTH_DOMAIN=my-manga-editor.firebaseapp.com
```

### Step 9.2: Use flutter_dotenv

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Load in `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // ... rest of initialization
}
```

---

## Part 10: Verify Setup

### Checklist

- [ ] Firebase project created
- [ ] Authentication enabled (Google provider)
- [ ] Firestore database created
- [ ] Security rules deployed
- [ ] OAuth consent screen configured
- [ ] OAuth client IDs created (Web, iOS, Android)
- [ ] FlutterFire CLI installed
- [ ] `firebase_options.dart` generated
- [ ] Platform-specific config files updated
- [ ] Firebase dependencies added to `pubspec.yaml`
- [ ] Firebase initialized in `main.dart`
- [ ] Offline persistence configured
- [ ] Test sign-in succeeds
- [ ] Test Firestore read/write succeeds

### Next Steps

1. Implement service layer: `FirebaseService`, `AuthService`
2. Create cloud models: `CloudManga`, `CloudMangaPage`, `EditLock`
3. Update repository to handle sync operations
4. Implement sync queue and periodic sync timer
5. Add UI components: sign-in button, sync status indicator
6. Implement lock management with heartbeat
7. Test multi-device sync workflow

---

## Troubleshooting

### Common Issues

**Issue**: "Default FirebaseApp is not initialized"
- **Fix**: Ensure `await Firebase.initializeApp()` is called before `runApp()`

**Issue**: "Google Sign-In fails on iOS"
- **Fix**: Verify `REVERSED_CLIENT_ID` in `Info.plist` matches `GoogleService-Info.plist`

**Issue**: "Permission denied" in Firestore
- **Fix**: Check security rules, ensure `request.auth.uid == userId`

**Issue**: "SHA-1 fingerprint mismatch" (Android)
- **Fix**: Re-generate SHA-1 from keystore and update OAuth client in Google Cloud Console

**Issue**: "Firestore offline persistence not working"
- **Fix**: Call `configureFirestore()` after `Firebase.initializeApp()` but before any Firestore operations

---

## References

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
