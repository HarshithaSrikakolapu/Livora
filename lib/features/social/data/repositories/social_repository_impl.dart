import 'dart:typed_data';
import 'package:Livora/features/social/data/datasources/social_remote_data_source.dart';
import 'package:Livora/features/social/domain/entities/post.dart';
import 'package:Livora/features/social/domain/entities/comment.dart';
import 'package:Livora/features/social/domain/entities/relationship.dart';
import 'package:Livora/features/auth/domain/entities/user.dart';
import 'package:Livora/features/social/domain/repositories/social_repository.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource _remoteDataSource;

  SocialRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createPost(Post post) async {
    return _remoteDataSource.createPost(post);
  }
  @override
Future<void> removeConnection(String currentUserId, String targetUserId) {
  return _remoteDataSource.removeConnection(currentUserId, targetUserId);
}
  @override
  Future<void> deletePost(String postId) async {
    return _remoteDataSource.deletePost(postId);
  }

  @override
  Future<void> likePost(String postId, String userId) {
    return _remoteDataSource.likePost(postId, userId);
  }

  @override
  Future<void> addComment(String postId, String text, String userId, String userName, String? userAvatar) {
    return _remoteDataSource.addComment(postId, text, userId, userName, userAvatar);
  }

  @override
  Stream<List<Comment>> getComments(String postId) {
    return _remoteDataSource.getComments(postId);
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
  Future<String> uploadPostImage(Uint8List data, String fileName) {
    return _remoteDataSource.uploadPostImage(data, fileName);
  }

  @override
  Future<void> sendConnectionRequest(String currentUserId, String userName, String? userAvatar, String targetUserId) {
    return _remoteDataSource.sendConnectionRequest(currentUserId, userName, userAvatar, targetUserId);
  }

  @override
  Future<void> acceptConnectionRequest(String currentUserId, String fromUserId) {
    if (_remoteDataSource is SocialRemoteDataSourceImpl) {
       return (_remoteDataSource).acceptRequest(currentUserId, fromUserId);
    } else {
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

