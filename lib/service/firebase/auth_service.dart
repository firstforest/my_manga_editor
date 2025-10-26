import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

/// Service for handling Google Sign-In authentication
/// Wraps GoogleSignIn and FirebaseAuth functionality
class AuthService {
  AuthService({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  static const _scopes = ['email', 'profile'];
  static const _webClientId =
      '948924085739-adqjuonj6bf2le0kscqisgoptfjhbm1l.apps.googleusercontent.com';

  bool _initialized = false;

  /// Initialize Google Sign-In (required in v7.x)
  /// Must be called before using any sign-in methods
  Future<void> initialize() async {
    if (_initialized) return;

    await _googleSignIn.initialize(
      // Web requires explicit client ID
      clientId: kIsWeb ? _webClientId : null,
    );
    _initialized = true;
  }

  /// Get the current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with Google account
  /// Returns the authenticated User or null if sign-in was cancelled
  Future<User?> signInWithGoogle() async {
    try {
      // Web platform: Use Firebase Auth popup (simpler and recommended)
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        // Sign in with popup
        final userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);
        return userCredential.user;
      }

      // Mobile/Desktop platforms: Use google_sign_in package
      // Ensure initialized
      await initialize();

      // Check if platform supports authenticate() method
      if (!_googleSignIn.supportsAuthenticate()) {
        throw AuthException(
          'This platform does not support Google Sign-In authentication',
        );
      }

      // Authenticate with Google (v7.x API)
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate(scopeHint: _scopes);

      // Get ID token from authentication
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // Get access token from authorization client
      final authorization =
          await googleUser.authorizationClient.authorizeScopes(_scopes);
      final accessToken = authorization.accessToken;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      throw AuthException(
        'Firebase authentication failed: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      // Handle other errors
      throw AuthException('Sign-in failed: $e');
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Sign-out failed: $e');
    }
  }

  /// Check if user is currently signed in
  bool get isSignedIn => _firebaseAuth.currentUser != null;
}

/// Exception thrown when authentication operations fail
class AuthException implements Exception {
  AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Provider for FirebaseAuth instance
@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

/// Provider for GoogleSignIn instance
@riverpod
GoogleSignIn googleSignIn(Ref ref) {
  // Version 7.x uses singleton pattern
  return GoogleSignIn.instance;
}

/// Provider for AuthService
@riverpod
AuthService authService(Ref ref) {
  return AuthService(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
}
