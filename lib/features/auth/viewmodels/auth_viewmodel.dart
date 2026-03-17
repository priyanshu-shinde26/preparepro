import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  const AuthState({this.isLoading = false, this.error});
  AuthState copyWith({bool? isLoading, String? error}) =>
      AuthState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

class AuthViewModelNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthViewModelNotifier(this._ref) : super(const AuthState());

  Future<String?> signInWithEmail({required String email, required String password}) async {
    state = const AuthState(isLoading: true);
    try {
      await _ref.read(authServiceProvider).signInWithEmail(email: email, password: password);
      state = const AuthState();
      return null;
    } catch (e) {
      state = const AuthState();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AuthState(isLoading: true);
    try {
      await _ref.read(authServiceProvider).signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      state = const AuthState();
      return null;
    } catch (e) {
      state = const AuthState();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> signInWithGoogle() async {
    state = const AuthState(isLoading: true);
    try {
      await _ref.read(authServiceProvider).signInWithGoogle();
      state = const AuthState();
      return null;
    } catch (e) {
      state = const AuthState();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> resetPassword(String email) async {
    await _ref.read(authServiceProvider).resetPassword(email);
  }

  Future<void> signOut() async {
    await _ref.read(authServiceProvider).signOut();
  }
}

final authViewModelProvider =
StateNotifierProvider<AuthViewModelNotifier, AuthState>(
      (ref) => AuthViewModelNotifier(ref),
);