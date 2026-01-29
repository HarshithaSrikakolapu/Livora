import '../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String accountType,
  });
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });
  
  Future<void> logout();
  
  Future<User?> getCurrentUser();
}
