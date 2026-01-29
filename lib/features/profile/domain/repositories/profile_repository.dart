import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<void> addFavoriteOrganization(String userId, String organizationId);
  Future<void> removeFavoriteOrganization(String userId, String organizationId);
}
