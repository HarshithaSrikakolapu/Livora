import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/auth/domain/entities/user.dart';
import 'package:Livora/features/auth/data/services/firebase_auth_service.dart';

class FirebaseAuthRepository {
  final FirebaseAuthService _authService;
  
  FirebaseAuthRepository(this._authService);
  
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String accountType,
  }) async {
    return await _authService.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      accountType: accountType,
    );
  }
  
  Future<User> login({
    required String email,
    required String password,
  }) async {
    return await _authService.login(
      email: email,
      password: password,
    );
  }
  
  Future<void> logout() async {
    await _authService.logout();
  }
  
  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUserData();
  }
  
  Stream<User?> watchAuthState() async* {
    await for (final firebaseUser in _authService.authStateChanges) {
      if (firebaseUser == null) {
        yield null;
      } else {
        yield await _authService.getCurrentUserData();
      }
    }
  }
  
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}

// Providers
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthServiceProvider));
});
