import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/core/config/app_config.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;
  
  SecureStorage(this._storage);
  
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConfig.accessTokenKey, value: token);
  }
  
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConfig.accessTokenKey);
  }
  
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConfig.refreshTokenKey, value: token);
  }
  
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConfig.refreshTokenKey);
  }
  
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: AppConfig.userDataKey, value: userData);
  }
  
  Future<String?> getUserData() async {
    return await _storage.read(key: AppConfig.userDataKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConfig.userIdKey, value: userId);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: AppConfig.userRoleKey, value: role);
  }

  
  Future<void> deleteTokens() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userDataKey);
  }
  
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

// Provider
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  ));
});
