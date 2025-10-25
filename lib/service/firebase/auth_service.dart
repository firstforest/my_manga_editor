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

  /// Get the current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with Google account
  /// Returns the authenticated User or null if sign-in was cancelled
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain auth details from the signed-in Google account
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
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
  return GoogleSignIn(
    // Web requires explicit client ID
    // Get from Google Cloud Console OAuth 2.0 Client IDs (Web application type)
    clientId: kIsWeb
        ? '948924085739-adqjuonj6bf2le0kscqisgoptfjhbm1l.apps.googleusercontent.com'
        : null,
    scopes: [
      'email',
      'profile',
    ],
  );
}

/// Provider for AuthService
@riverpod
AuthService authService(Ref ref) {
  return AuthService(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
}
