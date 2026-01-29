import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  
  AuthRepositoryImpl(this._apiClient, this._secureStorage);
  
  @override
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String accountType,
  }) async {
    final response = await _apiClient.post('/auth/register', data: {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'accountType': accountType,
    });
    
    final userData = response.data['data'];
    return User.fromJson(userData);
  }
  
  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    final data = response.data['data'];
    
    // Save tokens
    await _secureStorage.saveAccessToken(data['accessToken']);
    await _secureStorage.saveRefreshToken(data['refreshToken']);
    
    // Save user data
    final user = User.fromJson(data['user']);
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));
    
    return {
      'user': user,
      'accessToken': data['accessToken'],
      'refreshToken': data['refreshToken'],
    };
  }
  
  @override
  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
    await _secureStorage.deleteTokens();
  }
  
  @override
  Future<User?> getCurrentUser() async {
    final userData = await _secureStorage.getUserData();
    if (userData == null) return null;
    
    final json = jsonDecode(userData);
    return User.fromJson(json);
  }
}

// Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});
