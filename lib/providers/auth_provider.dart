import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// A single shared instance of AuthService
// Any provider that needs AuthService reads this instead of creating its own
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Listens to Firebase's auth state stream
// Emits User? — a Firebase User object when logged in, null when logged out
// This is the source of truth for whether someone is authenticated
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Fetches and holds the full UserModel (with role, skillTags, bio etc.)
// for whoever is currently logged in
// It depends on authStateProvider — when auth state changes, this rebuilds
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authServiceProvider).getUserById(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Manages the auth actions — login, register, logout
// This is a StateNotifier which means it holds state and can change it
// The state here is a simple string — either null (no error) or an error message
class AuthNotifier extends StateNotifier<String?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null);

  // REGISTER
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    state = null; // clear any previous error
    try {
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      return true;
    } catch (e) {
      state = e.toString(); // store error message in state
      return false;
    }
  }

  // LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = null;
    try {
      await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    state = null;
    await _authService.signOut();
  }
}

// The provider that exposes AuthNotifier to the UI
// Screens call ref.read(authNotifierProvider.notifier).login() to trigger actions
// Screens call ref.watch(authNotifierProvider) to read the error message
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});