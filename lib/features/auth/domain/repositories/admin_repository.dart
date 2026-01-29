import '../../domain/entities/app_user.dart';

abstract class AdminRepository {
  Future<List<AppUser>> getPendingUsers();
  Future<void> approveUser(String userId);
  Future<void> deactivateUser(String userId);
}
