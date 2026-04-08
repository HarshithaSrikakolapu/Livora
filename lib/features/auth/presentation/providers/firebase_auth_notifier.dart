import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:Livora/features/auth/data/repositories/firebase_auth_repository.dart';
import 'auth_state.dart';

class FirebaseAuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthRepository _authRepository;
  
  FirebaseAuthNotifier(this._authRepository) : super(const AuthInitial()) {
    checkAuthStatus();
  }
  
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (user != null) {
        if (user.isApproved) {
          state = Authenticated(user);
        } else {
          state = PendingApproval(user);
        }
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      state = const Unauthenticated();
    }
  }
  
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      
      if (user.isApproved) {
        state = Authenticated(user);
      } else {
        state = PendingApproval(user);
      }
    } catch (e) {
      state = AuthError(e.toString()); 
    }
  }
  
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String accountType,
  }) async {
    state = const AuthLoading();
    
    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        accountType: accountType,
      );
      
      if (user.isApproved) {
        state = Authenticated(user);
      } else {
        state = PendingApproval(user);
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
  
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = const Unauthenticated();
    } catch (e) {
      state = const Unauthenticated();
    }
  }
  
  Future<void> sendPasswordReset(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        if (user.isApproved) {
            state = Authenticated(user);
        } else {
            state = PendingApproval(user);
        }
      }
    } catch (e) {
      debugPrint('Failed to refresh user: $e');
    }
  }
}

// Provider
final firebaseAuthNotifierProvider = StateNotifierProvider<FirebaseAuthNotifier, AuthState>((ref) {
  return FirebaseAuthNotifier(ref.watch(firebaseAuthRepositoryProvider));
});


