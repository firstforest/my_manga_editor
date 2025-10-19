import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/repository/auth_repository.dart';
import 'package:my_manga_editor/service/firebase/auth_service.dart';

/// Widget that displays Google Sign-In and Sign-Out functionality
/// Shows current user's email when signed in
class SignInButton extends HookConsumerWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateStreamProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    return authState.when(
      data: (user) {
        if (user != null) {
          // User is signed in - show user info and sign out button
          return _buildSignedInView(
            context,
            user,
            authRepository,
            isLoading,
            errorMessage,
          );
        } else {
          // User is signed out - show sign in button
          return _buildSignInButton(
            context,
            authRepository,
            isLoading,
            errorMessage,
          );
        }
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text(
        'Auth error: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildSignInButton(
    BuildContext context,
    AuthRepository authRepository,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: isLoading.value
              ? null
              : () async {
                  isLoading.value = true;
                  errorMessage.value = null;

                  try {
                    final user = await authRepository.signInWithGoogle();
                    if (user == null) {
                      // User cancelled sign-in
                      errorMessage.value = 'Sign-in was cancelled';
                    }
                  } on AuthException catch (e) {
                    errorMessage.value = e.message;
                  } catch (e) {
                    errorMessage.value = 'Unexpected error: $e';
                  } finally {
                    isLoading.value = false;
                  }
                },
          icon: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.login),
          label: Text(isLoading.value ? 'Signing in...' : 'Sign in with Google'),
        ),
        if (errorMessage.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessage.value!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSignedInView(
    BuildContext context,
    User user,
    AuthRepository authRepository,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? Text(user.displayName?[0] ?? user.email?[0] ?? '?')
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.displayName ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Sign out button
        ElevatedButton.icon(
          onPressed: isLoading.value
              ? null
              : () async {
                  isLoading.value = true;
                  errorMessage.value = null;

                  try {
                    await authRepository.signOut();
                  } on AuthException catch (e) {
                    errorMessage.value = e.message;
                  } catch (e) {
                    errorMessage.value = 'Unexpected error: $e';
                  } finally {
                    isLoading.value = false;
                  }
                },
          icon: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
          label: Text(isLoading.value ? 'Signing out...' : 'Sign out'),
        ),
        if (errorMessage.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessage.value!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
