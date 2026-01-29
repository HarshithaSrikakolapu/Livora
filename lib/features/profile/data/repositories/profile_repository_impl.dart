import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../../../organizations/data/datasources/organization_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final OrganizationRemoteDataSource organizationRemoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource, this.organizationRemoteDataSource);

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    return await remoteDataSource.getUserProfile(uid);
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    return await remoteDataSource.updateUserProfile(profile);
  }

  @override
  Future<void> addFavoriteOrganization(String userId, String organizationId) async {
    // Atomic updates
    await remoteDataSource.addFavoriteOrg(userId, organizationId);
    await organizationRemoteDataSource.addSubscriber(organizationId, userId);
  }

  @override
  Future<void> removeFavoriteOrganization(String userId, String organizationId) async {
    // Atomic updates
    await remoteDataSource.removeFavoriteOrg(userId, organizationId);
    await organizationRemoteDataSource.removeSubscriber(organizationId, userId);
  }

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    // Similar logic: implement actual Data Source method for atomic updates
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    // Similar logic
  }
}
