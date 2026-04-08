
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:Livora/features/social/data/datasources/social_remote_data_source.dart';
import 'package:Livora/features/social/data/repositories/social_repository_impl.dart';
import 'package:Livora/features/social/domain/repositories/social_repository.dart';
import 'package:Livora/features/social/domain/usecases/post_usecases.dart';
import 'package:Livora/features/social/domain/usecases/connection_usecases.dart';
import 'package:Livora/features/social/domain/usecases/get_user_profile.dart'; // Import
import 'package:Livora/features/social/domain/usecases/update_user_profile.dart'; // Import
import 'package:Livora/features/social/domain/usecases/toggle_like_post.dart'; // Import
import 'package:Livora/features/social/domain/entities/post.dart';
import 'package:Livora/features/social/domain/entities/comment.dart'; // Import
import 'package:Livora/features/social/domain/entities/relationship.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/features/auth/domain/entities/user.dart'; // Import User
import 'package:Livora/features/social/domain/usecases/remove_connection.dart';
// --- Data Layer ---
final socialRemoteDataSourceProvider = Provider<SocialRemoteDataSource>((ref) {
  return SocialRemoteDataSourceImpl(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepositoryImpl(ref.watch(socialRemoteDataSourceProvider));
});
final removeConnectionProvider =
    Provider((ref) => RemoveConnection(ref.watch(socialRepositoryProvider)));
// --- Domain Layer (Use Cases) ---

// Posts
final createPostProvider = Provider((ref) => CreatePost(ref.watch(socialRepositoryProvider)));
final getGlobalFeedProvider = Provider((ref) => GetGlobalFeed(ref.watch(socialRepositoryProvider)));
final getUserPostsProvider = Provider((ref) => GetUserPosts(ref.watch(socialRepositoryProvider)));
final uploadPostImageProvider = Provider((ref) => UploadPostImage(ref.watch(socialRepositoryProvider)));
final getUserProfileProvider = Provider((ref) => GetUserProfile(ref.watch(socialRepositoryProvider)));
final updateUserProfileProvider = Provider((ref) => UpdateUserProfile(ref.watch(socialRepositoryProvider)));
final toggleLikePostProvider = Provider((ref) => ToggleLikePost(ref.watch(socialRepositoryProvider))); // Add Provider

// Comments
final commentsStreamProvider = StreamProvider.autoDispose.family<List<Comment>, String>((ref, postId) {
  return ref.watch(socialRepositoryProvider).getComments(postId);
});

// Connections
final sendConnectionRequestProvider = Provider((ref) => SendConnectionRequest(ref.watch(socialRepositoryProvider)));
final acceptConnectionRequestProvider = Provider((ref) => AcceptConnectionRequest(ref.watch(socialRepositoryProvider)));
final getPendingRequestsProvider = Provider((ref) => GetPendingRequests(ref.watch(socialRepositoryProvider)));
final getConnectionStatusProvider = Provider((ref) => GetConnectionStatus(ref.watch(socialRepositoryProvider)));
final getConnectionsProvider = Provider((ref) => GetConnections(ref.watch(socialRepositoryProvider)));

// --- Presentation Layer (Streams/Futures) ---

final globalFeedStreamProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  final getFeed = ref.watch(getGlobalFeedProvider);
  return getFeed(limit: 50);
});

final userPostsStreamProvider = StreamProvider.autoDispose.family<List<Post>, String>((ref, userId) {
  final getUserPosts = ref.watch(getUserPostsProvider);
  return getUserPosts(userId);
});

final pendingRequestsStreamProvider = StreamProvider.autoDispose<List<Relationship>>((ref) {
  final authState = ref.watch(firebaseAuthNotifierProvider);
  if (authState is Authenticated) {
    return ref.watch(getPendingRequestsProvider).call(authState.user.id);
  }
  return Stream.value([]);
});

final connectionsStreamProvider = StreamProvider.autoDispose<List<Relationship>>((ref) {
  final authState = ref.watch(firebaseAuthNotifierProvider);
  if (authState is Authenticated) {
    return ref.watch(getConnectionsProvider).call(authState.user.id);
  }
  return Stream.value([]);
});

final connectionStatusProvider = FutureProvider.autoDispose.family<Relationship?, String>((ref, targetUserId) async {
  final authState = ref.watch(firebaseAuthNotifierProvider);
  if (authState is Authenticated) {
    return ref.watch(getConnectionStatusProvider).call(authState.user.id, targetUserId);
  }
  return null;
});

final userProfileFutureProvider = FutureProvider.autoDispose.family<User?, String>((ref, userId) {
  return ref.watch(getUserProfileProvider).call(userId);
});


