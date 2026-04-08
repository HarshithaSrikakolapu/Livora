import 'package:Livora/features/auth/domain/entities/user.dart';

abstract class AdminRepository {
  Future<List<User>> getPendingUsers();
  Future<void> approveUser(String userId);
  Future<void> deactivateUser(String userId);
}

