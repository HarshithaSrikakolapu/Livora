import 'dart:typed_data';
import 'package:Livora/features/social/domain/entities/post.dart';
import 'package:Livora/features/social/domain/entities/relationship.dart';
import 'package:Livora/features/social/domain/entities/comment.dart';
import 'package:Livora/features/auth/domain/entities/user.dart';

abstract class SocialRepository {
  // Posts
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Stream<List<Post>> getGlobalFeed({int limit = 20});
  Stream<List<Post>> getUserPosts(String userId);
  Future<String> uploadPostImage(Uint8List data, String fileName);
  Future<void> likePost(String postId, String userId); 
  Future<void> addComment(String postId, String text, String userId, String userName, String? userAvatar);
  Stream<List<Comment>> getComments(String postId);

  // Connections
  Future<void> sendConnectionRequest(String currentUserId, String userName, String? userAvatar, String targetUserId);
  Future<void> acceptConnectionRequest(String currentUserId, String fromUserId);
  Stream<List<Relationship>> getPendingRequests(String userId);
  Stream<List<Relationship>> getConnections(String userId);
  Future<Relationship?> getConnectionStatus(String currentUserId, String targetUserId);
  Future<void> removeConnection(String currentUserId, String targetUserId);
  Future<User?> getUserProfile(String userId);
  Future<void> updateUserProfile(User user);
}

