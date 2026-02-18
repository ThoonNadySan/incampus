import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incampus/models/user_model.dart';
import 'package:incampus/services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider((ref) => AuthService());

// Auth state provider - tracks Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUserModel;
});

// Sign up provider
final signUpProvider =
    FutureProvider.family<UserModel?, SignUpParams>((ref, params) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.signUpWithEmail(
    email: params.email,
    password: params.password,
    displayName: params.displayName,
  );
});

// Sign in provider
final signInProvider =
    FutureProvider.family<UserModel?, SignInParams>((ref, params) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.signInWithEmail(
    email: params.email,
    password: params.password,
  );
});

// Sign out provider
final signOutProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authServiceProvider);
  await authService.signOut();
  ref.invalidate(currentUserProvider);
});

// Update profile provider
final updateProfileProvider =
    FutureProvider.family<void, UpdateProfileParams>((ref, params) async {
  final authService = ref.watch(authServiceProvider);
  await authService.updateUserProfile(
    displayName: params.displayName,
    photoUrl: params.photoUrl,
  );
});

// Sign up parameters class
class SignUpParams {
  final String email;
  final String password;
  final String? displayName;

  SignUpParams({
    required this.email,
    required this.password,
    this.displayName,
  });
}

// Sign in parameters class
class SignInParams {
  final String email;
  final String password;

  SignInParams({
    required this.email,
    required this.password,
  });
}

// Update profile parameters class
class UpdateProfileParams {
  final String? displayName;
  final String? photoUrl;

  UpdateProfileParams({
    this.displayName,
    this.photoUrl,
  });
}
