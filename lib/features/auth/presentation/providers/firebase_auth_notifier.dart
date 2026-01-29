import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/services/firebase_auth_service.dart';
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
  
  Future<void> login(String email, String password) async {
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
    } on UnapprovedUserException catch (e) {
      // User exists but not approved
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = PendingApproval(user);
      } else {
        state = AuthError(e.message, errorCode: e.code);
      }
    } on AuthException catch (e) {
      state = AuthError(e.message, errorCode: e.code);
    } catch (e) {
      state = const AuthError('An unexpected error occurred. Please try again.');
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
    } on AuthException catch (e) {
      state = AuthError(e.message, errorCode: e.code);
    } catch (e) {
      state = const AuthError('An unexpected error occurred. Please try again.');
    }
  }
  
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = const Unauthenticated();
    } catch (e) {
      // Even if logout fails, clear local state
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
    // Reloads the current user data from Firestore without triggering loading state if possible,
    // or just re-runs checkAuthStatus but we might want to avoid full screen loading.
    // simpler:
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
      // If refresh fails, keep current state or handle error
      debugPrint('Failed to refresh user: $e');
    }
  }
}

// Provider
final firebaseAuthNotifierProvider = StateNotifierProvider<FirebaseAuthNotifier, AuthState>((ref) {
  return FirebaseAuthNotifier(ref.watch(firebaseAuthRepositoryProvider));
});
