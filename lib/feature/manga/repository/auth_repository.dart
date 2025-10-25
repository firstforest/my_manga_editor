import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_manga_editor/service/firebase/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Repository for authentication operations
/// Provides a clean interface between the UI and AuthService
class AuthRepository {
  AuthRepository({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  /// Get the current authenticated user
  User? get currentUser => _authService.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Check if user is currently signed in
  bool get isSignedIn => _authService.isSignedIn;

  /// Sign in with Google account
  /// Returns the authenticated User or null if sign-in was cancelled
  /// Throws AuthException if sign-in fails
  Future<User?> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  /// Sign out from the current session
  /// Throws AuthException if sign-out fails
  Future<void> signOut() async {
    await _authService.signOut();
  }
}

/// Provider for AuthRepository
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
  );
}

/// Provider for current authentication state
/// Provides a stream of the current user (null if signed out)
@riverpod
Stream<User?> authStateStream(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
}

/// Provider for current user
/// Provides the current user or null if signed out
/// This is a computed provider that listens to authStateStream
@riverpod
User? currentUser(Ref ref) {
  // Watch the auth state stream to get real-time updates
  final asyncUser = ref.watch(authStateStreamProvider);
  return asyncUser.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
}
