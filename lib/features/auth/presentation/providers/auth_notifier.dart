import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_state.dart';
import '../../../../core/network/api_client.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  
  AuthNotifier(this._authRepository) : super(const AuthInitial()) {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
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
      final result = await _authRepository.login(
        email: email,
        password: password,
      );
      
      final user = result['user'];
      
      if (user.isApproved) {
        state = Authenticated(user);
      } else {
        state = PendingApproval(user);
      }
    } on ApiException catch (e) {
      state = AuthError(e.message, errorCode: e.errorCode);
    } catch (e) {
      state = AuthError('An unexpected error occurred. Please try again.');
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
      
      state = PendingApproval(user);
    } on ApiException catch (e) {
      state = AuthError(e.message, errorCode: e.errorCode);
    } catch (e) {
      state = AuthError('An unexpected error occurred. Please try again.');
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
}

// Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
