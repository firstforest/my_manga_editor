# Quickstart Guide: Firebase Cloud Storage Implementation

**Feature**: Firebase Cloud Storage for My Manga Editor
**Date**: 2025-10-18
**Target Audience**: Developers implementing the feature

## Overview

This guide provides step-by-step instructions for implementing Firebase Cloud Storage in My Manga Editor, replacing the existing Drift database. Follow these phases sequentially to ensure a smooth migration.

---

## Prerequisites

- Flutter SDK 3.32.4 or later
- Firebase account (free Spark plan is sufficient for development)
- Existing My Manga Editor codebase
- Understanding of Riverpod and Freezed

---

## Phase 1: Firebase Project Setup (30 minutes)

### Step 1.1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `my-manga-editor` (or your preference)
4. Disable Google Analytics (optional for this project)
5. Click "Create project"

### Step 1.2: Enable Firestore

1. In Firebase Console, go to "Build" → "Firestore Database"
2. Click "Create database"
3. Select "Start in **test mode**" (we'll add security rules later)
4. Choose location: `asia-northeast1` (Tokyo) for Japan or closest region
5. Click "Enable"

### Step 1.3: Enable Authentication

1. Go to "Build" → "Authentication"
2. Click "Get started"
3. Enable "Email/Password" provider
4. Save

### Step 1.4: Add Firebase to Flutter App

Install FlutterFire CLI:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

Configure Firebase for your Flutter app:

```bash
cd C:\Users\firstforest\projects\my_manga_editor

# Configure Firebase (interactive)
flutterfire configure
```

**Interactive prompts**:
- Select the Firebase project you created
- Select platforms: Windows, macOS, Linux, iOS, Android, Web (all)
- This generates `lib/firebase_options.dart` and updates platform configs

---

## Phase 2: Add Dependencies (10 minutes)

### Step 2.1: Update pubspec.yaml

Add Firebase packages to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Existing dependencies (keep these)
  hooks_riverpod: ^3.0.0-dev.15
  riverpod_annotation: ^3.0.0-dev.8
  freezed_annotation: ^3.0.6
  json_annotation: ^4.9.0
  flutter_quill: ^11.4.0

  # Firebase (NEW)
  firebase_core: ^3.10.0
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.7.2

  # Connectivity monitoring (NEW)
  connectivity_plus: ^6.1.2

  # Keep Drift temporarily for migration
  drift: ^2.22.1
  drift_flutter: ^0.2.2

dev_dependencies:
  # Existing dev dependencies (keep these)
  build_runner: ^2.4.13
  freezed: ^3.0.6
  json_serializable: ^6.8.0
  riverpod_generator: ^3.0.0-dev.16

  # Testing (NEW)
  fake_cloud_firestore: ^3.0.3
```

### Step 2.2: Install Packages

```bash
flutter pub get
```

---

## Phase 3: Initialize Firebase (15 minutes)

### Step 3.1: Update main.dart

Edit `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Step 3.2: Test Firebase Connection

Run the app and check for errors:

```bash
flutter run
```

You should see Firebase initialization logs in the console.

---

## Phase 4: Create Data Models (30 minutes)

### Step 4.1: Update Manga Model

Edit `lib/models/manga.dart` to add Firestore support:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'manga.freezed.dart';
part 'manga.g.dart';

// Custom JsonConverter for Quill Delta
class DeltaConverter implements JsonConverter<Delta, Map<String, dynamic>> {
  const DeltaConverter();

  @override
  Delta fromJson(Map<String, dynamic> json) {
    return Delta.fromJson(json['ops'] ?? []);
  }

  @override
  Map<String, dynamic> toJson(Delta delta) {
    return {'ops': delta.toJson()};
  }
}

// Custom JsonConverter for Firestore Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

enum MangaStartPage {
  left,
  right;

  MangaStartPage get reverted => switch (this) {
        MangaStartPage.left => MangaStartPage.right,
        MangaStartPage.right => MangaStartPage.left,
      };
}

typedef MangaId = String;
typedef MangaPageId = String;

@freezed
class Manga with _$Manga {
  const factory Manga({
    required MangaId id,
    required String name,
    required MangaStartPage startPage,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

@freezed
class MangaPage with _$MangaPage {
  const factory MangaPage({
    required MangaPageId id,
    required int pageIndex,
    @DeltaConverter() required Delta memoDelta,
    @DeltaConverter() required Delta stageDirectionDelta,
    @DeltaConverter() required Delta dialoguesDelta,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _MangaPage;

  factory MangaPage.fromJson(Map<String, dynamic> json) =>
      _$MangaPageFromJson(json);
}
```

### Step 4.2: Generate Code

Run build_runner (required after model changes):

```bash
dart run build_runner build -d
```

This generates:
- `manga.freezed.dart`
- `manga.g.dart`

---

## Phase 5: Implement Firestore Repository (1-2 hours)

### Step 5.1: Create Firestore Repository

Create `lib/firebase/firestore/firestore_manga_repository.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:my_manga_editor/common/logger.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_manga_repository.g.dart';

@Riverpod(keepAlive: true)
FirestoreMangaRepository firestoreMangaRepository(Ref ref) {
  return FirestoreMangaRepository(FirebaseFirestore.instance);
}

class FirestoreMangaRepository {
  FirestoreMangaRepository(this._firestore);

  final FirebaseFirestore _firestore;

  // Helper: Manga collection reference with converter
  CollectionReference<Manga> _mangasCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('mangas')
        .withConverter<Manga>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data()!;
            return Manga.fromJson({...data, 'id': snapshot.id});
          },
          toFirestore: (manga, _) {
            final json = manga.toJson();
            json.remove('id'); // Firestore manages ID
            return json;
          },
        );
  }

  // Helper: Pages subcollection reference with converter
  CollectionReference<MangaPage> _pagesCollection(String userId, MangaId mangaId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('mangas')
        .doc(mangaId)
        .collection('pages')
        .withConverter<MangaPage>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data()!;
            return MangaPage.fromJson({...data, 'id': snapshot.id});
          },
          toFirestore: (page, _) {
            final json = page.toJson();
            json.remove('id');
            return json;
          },
        );
  }

  // Create new manga
  Future<MangaId> createNewManga(String userId) async {
    logger.d('createNewManga for user: $userId');
    final now = DateTime.now();
    final docRef = await _mangasCollection(userId).add(
      Manga(
        id: '',
        name: '無名の傑作',
        startPage: MangaStartPage.left,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return docRef.id;
  }

  // Watch manga stream
  Stream<Manga?> watchManga(String userId, MangaId id) {
    logger.d('watchManga: $id for user: $userId');
    return _mangasCollection(userId).doc(id).snapshots().map((snapshot) {
      return snapshot.exists ? snapshot.data() : null;
    });
  }

  // Watch all manga list
  Stream<List<Manga>> watchAllMangaList(String userId) {
    logger.d('watchAllMangaList for user: $userId');
    return _mangasCollection(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Update manga name
  Future<void> updateMangaName(String userId, MangaId id, String name) async {
    logger.d('updateMangaName: $id, $name');
    await _mangasCollection(userId).doc(id).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update start page
  Future<void> updateStartPage(String userId, MangaId id, MangaStartPage startPage) async {
    logger.d('updateStartPage: $id, $startPage');
    await _mangasCollection(userId).doc(id).update({
      'startPage': startPage.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete manga with cascade
  Future<void> deleteManga(String userId, MangaId id) async {
    logger.d('deleteManga: $id');

    // Delete all pages first
    final pagesSnapshot = await _pagesCollection(userId, id).get();
    final batch = _firestore.batch();

    for (final doc in pagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete manga document
    batch.delete(_mangasCollection(userId).doc(id));

    await batch.commit();
  }

  // Create new manga page
  Future<MangaPageId> createNewMangaPage(String userId, MangaId mangaId) async {
    logger.d('createNewMangaPage for manga: $mangaId');

    // Get current max pageIndex
    final pagesSnapshot = await _pagesCollection(userId, mangaId)
        .orderBy('pageIndex', descending: true)
        .limit(1)
        .get();

    final nextIndex = pagesSnapshot.docs.isEmpty
        ? 0
        : (pagesSnapshot.docs.first.data().pageIndex + 1);

    final now = DateTime.now();
    final docRef = await _pagesCollection(userId, mangaId).add(
      MangaPage(
        id: '',
        pageIndex: nextIndex,
        memoDelta: Delta(),
        stageDirectionDelta: Delta(),
        dialoguesDelta: Delta(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return docRef.id;
  }

  // Watch manga page stream
  Stream<MangaPage?> watchMangaPage(String userId, MangaId mangaId, MangaPageId pageId) {
    logger.d('watchMangaPage: $mangaId/$pageId');
    return _pagesCollection(userId, mangaId).doc(pageId).snapshots().map((snapshot) {
      return snapshot.exists ? snapshot.data() : null;
    });
  }

  // Watch all page IDs
  Stream<List<MangaPageId>> watchAllMangaPageIdList(String userId, MangaId mangaId) {
    logger.d('watchAllMangaPageIdList for manga: $mangaId');
    return _pagesCollection(userId, mangaId)
        .orderBy('pageIndex')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Update page delta
  Future<void> updatePageDelta(
    String userId,
    MangaId mangaId,
    MangaPageId pageId,
    String deltaField,
    Delta delta,
  ) async {
    logger.d('updatePageDelta: $mangaId/$pageId/$deltaField');
    await _pagesCollection(userId, mangaId).doc(pageId).update({
      deltaField: {'ops': delta.toJson()},
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Reorder pages
  Future<void> reorderPages(String userId, MangaId mangaId, List<MangaPageId> orderedPageIds) async {
    logger.d('reorderPages for manga: $mangaId');
    final batch = _firestore.batch();

    for (int i = 0; i < orderedPageIds.length; i++) {
      final pageRef = _pagesCollection(userId, mangaId).doc(orderedPageIds[i]);
      batch.update(pageRef, {
        'pageIndex': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // Delete manga page
  Future<void> deleteMangaPage(String userId, MangaId mangaId, MangaPageId pageId) async {
    logger.d('deleteMangaPage: $mangaId/$pageId');
    await _pagesCollection(userId, mangaId).doc(pageId).delete();
  }
}
```

### Step 5.2: Generate Providers

```bash
dart run build_runner build -d
```

This generates `firestore_manga_repository.g.dart`.

---

## Phase 6: Implement Authentication (1 hour)

### Step 6.1: Create Auth Repository

Create `lib/firebase/auth/auth_repository.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_manga_editor/common/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
}

class AuthRepository {
  AuthRepository({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      logger.d('Signing up user: $email');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.d('User created: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      logger.e('Sign up error: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      logger.d('Signing in user: $email');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.d('User signed in: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      logger.e('Sign in error: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    logger.d('Signing out');
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      logger.d('Sending password reset to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      logger.e('Password reset error: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  AuthException _handleAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'weak-password' => const AuthException(
          message: 'パスワードが弱すぎます',
        ),
      'email-already-in-use' => const AuthException(
          message: 'このメールアドレスは既に使用されています',
        ),
      'user-not-found' => const AuthException(
          message: 'ユーザーが見つかりません',
        ),
      'wrong-password' => const AuthException(
          message: 'パスワードが正しくありません',
        ),
      'invalid-email' => const AuthException(
          message: 'メールアドレスの形式が正しくありません',
        ),
      _ => AuthException(message: '認証エラー: ${e.message}'),
    };
  }
}

class AuthException implements Exception {
  const AuthException({required this.message});
  final String message;

  @override
  String toString() => message;
}
```

### Step 6.2: Create Auth Providers

Create `lib/firebase/auth/auth_providers.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_manga_editor/firebase/auth/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@riverpod
User? currentUser(Ref ref) {
  return ref.watch(authStateChangesProvider).value;
}

@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(currentUserProvider)?.uid;
}

@riverpod
bool isSignedIn(Ref ref) {
  return ref.watch(currentUserProvider) != null;
}
```

### Step 6.3: Generate Auth Code

```bash
dart run build_runner build -d
```

---

## Phase 7: Deploy Security Rules (15 minutes)

### Step 7.1: Create firestore.rules

Create `firestore.rules` in project root:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);

      match /mangas/{mangaId} {
        allow read, write: if isOwner(userId);

        allow create: if request.resource.data.name is string
                      && request.resource.data.name.size() > 0
                      && request.resource.data.startPage in ['left', 'right'];

        match /pages/{pageId} {
          allow read, write: if isOwner(userId);

          allow create: if request.resource.data.pageIndex is int
                        && request.resource.data.pageIndex >= 0;
        }
      }
    }
  }
}
```

### Step 7.2: Deploy Rules

```bash
firebase deploy --only firestore:rules
```

---

## Phase 8: Testing (30 minutes)

### Step 8.1: Manual Testing Checklist

- [ ] Sign up with email/password
- [ ] Sign in with email/password
- [ ] Create new manga (appears in Firestore console)
- [ ] Update manga name (updates in real-time)
- [ ] Create manga page
- [ ] Edit page delta (memo, dialogue, stage direction)
- [ ] Reorder pages
- [ ] Delete page
- [ ] Delete manga
- [ ] Sign out
- [ ] Work offline (airplane mode)
- [ ] Reconnect (verify offline changes sync)

### Step 8.2: Check Firestore Console

Go to Firebase Console → Firestore Database and verify:
- `/users/{userId}/mangas` collection exists
- Manga documents have correct structure
- Pages subcollection exists under mangas
- Delta data is stored as structured maps (not JSON strings)

---

## Phase 9: Migration Implementation (2-3 hours)

See `research.md` section "Data Migration Strategy" for detailed migration code.

**Summary**:
1. Create `lib/firebase/migration/drift_to_firebase_migrator.dart`
2. Implement migration state tracking (SharedPreferences)
3. Create migration UI dialog
4. Test with sample data before full migration
5. Verify data integrity after migration
6. Clean up Drift data only after user confirmation

---

## Common Issues & Solutions

### Issue: "Firebase not initialized"

**Solution**: Ensure `Firebase.initializeApp()` is called in `main()` before `runApp()`.

### Issue: "Permission denied" errors

**Solution**: Check Firestore security rules are deployed and user is signed in.

### Issue: "Document doesn't exist" on watch

**Solution**: Firestore returns `null` for non-existent documents. Handle in UI:
```dart
mangaStream.when(
  data: (manga) => manga != null ? MangaWidget(manga) : Text('Not found'),
  ...
)
```

### Issue: Offline writes not syncing

**Solution**: Check `persistenceEnabled: true` in Firestore settings. Use connectivity monitoring to show offline status.

### Issue: Delta conversion errors

**Solution**: Verify `DeltaConverter` is correctly applied with `@DeltaConverter()` annotation in Freezed models.

---

## Performance Optimization

### Enable Firestore Persistence

Already done in Phase 3, but verify:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Use Stream Builders Wisely

- Don't rebuild entire widget trees on every stream update
- Use `select` to watch specific fields only
- Consider pagination for large lists (>100 items)

### Monitor Firestore Usage

Go to Firebase Console → Usage to track:
- Read/write operations
- Storage size
- Network bandwidth

---

## Next Steps

After completing this quickstart:

1. **Implement full authentication UI** (sign in/up pages)
2. **Add sync status indicator** (see `research.md` section 6)
3. **Implement Drift-to-Firestore migration** (see migration code in research)
4. **Test on all platforms** (Windows, macOS, Linux, mobile, web)
5. **Set up Firebase monitoring** (crashlytics, analytics optional)
6. **Deploy security rules to production**
7. **Remove Drift dependencies** after successful migration

---

## Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Cloud Firestore Guide](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Riverpod Documentation](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)

---

## Support

If you encounter issues:
1. Check Firebase Console logs
2. Review Firestore security rules
3. Verify authentication state (`currentUser` not null)
4. Check Flutter console for detailed error messages
5. Consult research.md for architectural decisions

**Quickstart Complete!** You now have a functional Firebase Cloud Storage implementation.
