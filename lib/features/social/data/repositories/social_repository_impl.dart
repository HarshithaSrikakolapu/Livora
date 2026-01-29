
import 'dart:io';
import 'package:edirectory_app/features/social/data/datasources/social_remote_data_source.dart';
import 'package:edirectory_app/features/social/domain/entities/post.dart';
import 'package:edirectory_app/features/social/domain/entities/comment.dart'; // Import
import 'package:edirectory_app/features/social/domain/entities/relationship.dart';
import 'package:edirectory_app/features/auth/domain/entities/user.dart';
import '../../domain/repositories/social_repository.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource _remoteDataSource;

  SocialRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createPost(Post post) async {
    return _remoteDataSource.createPost(post);
  }

  @override
  Future<void> deletePost(String postId) async {
    return _remoteDataSource.deletePost(postId);
  }

  @override
  Future<void> likePost(String postId, String userId) {
    if (_remoteDataSource is SocialRemoteDataSourceImpl) {
       return (_remoteDataSource as SocialRemoteDataSourceImpl).likePost(postId, userId);
    }
    throw UnimplementedError();
  }

  @override
  Future<void> addComment(String postId, String text, String userId, String userName, String? userAvatar) {
    if (_remoteDataSource is SocialRemoteDataSourceImpl) {
      return (_remoteDataSource as SocialRemoteDataSourceImpl).addComment(postId, text, userId, userName, userAvatar);
    }
    throw UnimplementedError();
  }

  @override
  Stream<List<Comment>> getComments(String postId) {
    if (_remoteDataSource is SocialRemoteDataSourceImpl) {
      return (_remoteDataSource as SocialRemoteDataSourceImpl).getComments(postId);
    }
    return Stream.value([]);
  }

  @override
  Stream<List<Post>> getGlobalFeed({int limit = 20}) {
    return _remoteDataSource.getGlobalFeed(limit: limit);
  }

  @override
  Stream<List<Post>> getUserPosts(String userId) {
    return _remoteDataSource.getUserPosts(userId);
  }

  @override
  Future<String> uploadPostImage(File file, String path) {
    return _remoteDataSource.uploadPostImage(file, path);
  }

  @override
  Future<void> sendConnectionRequest(String currentUserId, String userName, String? userAvatar, String targetUserId) {
    return _remoteDataSource.sendConnectionRequest(currentUserId, userName, userAvatar, targetUserId);
  }

  @override
  Future<void> acceptConnectionRequest(String currentUserId, String fromUserId) {
    // In strict schema, accepting usually means moving from requests to friends.
    // The previous implementation was: Future<void> acceptRequest(String requestId)
    // The data source has: acceptRequest(String currentUserId, String fromUserId)
    // We cast implementation specific calls here.
    if (_remoteDataSource is SocialRemoteDataSourceImpl) {
       return (_remoteDataSource as SocialRemoteDataSourceImpl).acceptRequest(currentUserId, fromUserId);
    } else {
        // Fallback or error if using a different implementation mock
        throw UnimplementedError('DataSource does not support acceptRequest with 2 args');
    }
  }

  @override
  Stream<List<Relationship>> getPendingRequests(String userId) {
    return _remoteDataSource.getPendingRequests(userId);
  }

  @override
  Stream<List<Relationship>> getConnections(String userId) {
    return _remoteDataSource.getConnections(userId);
  }

  @override
  Future<Relationship?> getConnectionStatus(String currentUserId, String targetUserId) {
    return _remoteDataSource.getConnectionStatus(currentUserId, targetUserId);
  }

  @override
  Future<User?> getUserProfile(String userId) async {
    final data = await _remoteDataSource.getUserProfile(userId);
    if (data != null) {
      return User.fromFirestore(data, userId);
    }
    return null;
  }

  @override
  Future<void> updateUserProfile(User user) {
    return _remoteDataSource.updateUserProfile(user.id, user.toFirestore());
  }
}
