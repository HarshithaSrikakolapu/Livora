
import 'dart:io';
import '../entities/post.dart';
import '../entities/relationship.dart';
import '../entities/comment.dart'; // Import
import '../../../auth/domain/entities/user.dart'; // Import User

abstract class SocialRepository {
  // Posts
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Stream<List<Post>> getGlobalFeed({int limit = 20});
  Stream<List<Post>> getUserPosts(String userId);
  Future<String> uploadPostImage(File file, String path);
  Future<void> likePost(String postId, String userId); 
  Future<void> addComment(String postId, String text, String userId, String userName, String? userAvatar); // Add addComment
  Stream<List<Comment>> getComments(String postId); // Add getComments

  // Connections
  Future<void> sendConnectionRequest(String currentUserId, String userName, String? userAvatar, String targetUserId);
  Future<void> acceptConnectionRequest(String currentUserId, String fromUserId);
  // Future<void> rejectConnectionRequest(String currentUserId, String fromUserId); // TODO: Implement rejection
  Stream<List<Relationship>> getPendingRequests(String userId);
  Stream<List<Relationship>> getConnections(String userId);
  Future<Relationship?> getConnectionStatus(String currentUserId, String targetUserId);
  
  Future<User?> getUserProfile(String userId);
  Future<void> updateUserProfile(User user);
}
