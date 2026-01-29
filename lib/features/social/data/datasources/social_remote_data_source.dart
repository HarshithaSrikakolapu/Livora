
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart'; // Import
import '../../domain/entities/relationship.dart';

abstract class SocialRemoteDataSource {
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId, String userId);
  Future<void> addComment(String postId, String text, String userId, String userName, String? userAvatar); // Add
  Stream<List<Comment>> getComments(String postId); // Add
  Stream<List<Post>> getGlobalFeed({int limit = 20});
  Stream<List<Post>> getUserPosts(String userId);
  
  Future<void> sendConnectionRequest(String currentUserId, String userName, String? userAvatar, String targetUserId);
  Future<void> acceptConnectionRequest(String requestId);
  Future<void> rejectConnectionRequest(String requestId);
  Stream<List<Relationship>> getPendingRequests(String userId);
  Future<Relationship?> getConnectionStatus(String currentUserId, String targetUserId);
  

  
  Future<String> uploadPostImage(File file, String path);
  
  // User Profile
  Future<Map<String, dynamic>?> getUserProfile(String userId);
  
  Stream<List<Relationship>> getConnections(String userId);
  
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data);
}

class SocialRemoteDataSourceImpl implements SocialRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  SocialRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<void> createPost(Post post) async {
    final docRef = _firestore.collection('posts').doc(); 
    final postWithId = Post(
      id: docRef.id,
      userId: post.userId,
      userName: post.userName,
      userAvatar: post.userAvatar,
      type: post.type,
      mediaUrl: post.mediaUrl,
      thumbnailUrl: post.thumbnailUrl,
      caption: post.caption,
      createdAt: DateTime.now(), // Will be overwritten by server timestamp
    );
    
    final data = postWithId.toFirestore();
    // Ensure accurate server timestamp
    data['createdAt'] = FieldValue.serverTimestamp();
    
    await docRef.set(data);
    
    // Increment post count for user
    await _firestore.collection('users').doc(post.userId).update({
      'stats.postsCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }
  
  @override
  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final userLikeRef = postRef.collection('likes').doc(userId);
    
    final likeDoc = await userLikeRef.get();
    
    if (likeDoc.exists) {
      // Unlike
      await userLikeRef.delete();
      await postRef.update({
        'likesCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      // Like
      await userLikeRef.set({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await postRef.update({
        'likesCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  @override
  Future<void> addComment(String postId, String text, String userId, String userName, String? userAvatar) async {
    final commentRef = _firestore.collection('posts').doc(postId).collection('comments').doc();
    
    await commentRef.set({
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // update comment count
     await _firestore.collection('posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  @override
  Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false) // Oldest first (like chat)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<Post>> getGlobalFeed({int limit = 20}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<Post>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // --- Connections (Strict Schema: connections/{userId}/friends/{friendId}) ---
  // Note: We also need connection_requests collection as per requirements.
  
  @override
  Future<void> sendConnectionRequest(String currentUserId, String userName, String? userAvatar, String targetUserId) async {
    // Check if request already exists
    final existing = await _firestore
        .collection('connection_requests')
        .doc(targetUserId)
        .collection('requests')
        .doc(currentUserId)
        .get();
        
    if (existing.exists) return;

    await _firestore
        .collection('connection_requests')
        .doc(targetUserId)
        .collection('requests')
        .doc(currentUserId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending', 
      'fromUserId': currentUserId,
      'fromUserName': userName,
      'fromUserAvatar': userAvatar,
    });
  }

  @override
  Future<void> acceptConnectionRequest(String requestId) async {
    // RequestId here is actually 'fromUserId' in the context of 'my' requests
    // But we need the context of WHO is accepting. 
    // This method signature might need adjustment or we assume the repo handles the 'who'.
    // Let's assume requestId = docId of the request which is the other user's ID
    
    // Implementation requires knowing current user. 
    // Refactoring signature to include currentUserId would be better, 
    // but for now let's assume the Repo handles it or we pass it in.
    
    throw UnimplementedError('Requires currentUserId to locate the request path');
  }
  
  // Revised method signature for clarity in implementation
  Future<void> acceptRequest(String currentUserId, String fromUserId) async {
    final batch = _firestore.batch();
    
    // Fetch details for denormalization
    final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
    final fromUserDoc = await _firestore.collection('users').doc(fromUserId).get();
    
    final currentUserName = currentUserDoc.data()?['fullName'];
    final currentUserAvatar = currentUserDoc.data()?['avatarUrl'];
    
    final fromUserName = fromUserDoc.data()?['fullName'];
    final fromUserAvatar = fromUserDoc.data()?['avatarUrl'];
    
    // 1. Add to my connections
    final myConnectionRef = _firestore
        .collection('connections')
        .doc(currentUserId)
        .collection('friends')
        .doc(fromUserId);
        
    batch.set(myConnectionRef, {
      'timestamp': FieldValue.serverTimestamp(),
      'friendName': fromUserName,
      'friendAvatar': fromUserAvatar,
    });
    
    // 2. Add to their connections
    final theirConnectionRef = _firestore
        .collection('connections')
        .doc(fromUserId)
        .collection('friends')
        .doc(currentUserId);
        
    batch.set(theirConnectionRef, {
      'timestamp': FieldValue.serverTimestamp(),
      'friendName': currentUserName,
      'friendAvatar': currentUserAvatar,
    });
    
    // 3. Delete request
    final requestRef = _firestore
        .collection('connection_requests')
        .doc(currentUserId)
        .collection('requests')
        .doc(fromUserId);
        
    batch.delete(requestRef);
    
    // 4. Update stats
    batch.update(_firestore.collection('users').doc(currentUserId), {
      'stats.connectionsCount': FieldValue.increment(1)
    });
    
    batch.update(_firestore.collection('users').doc(fromUserId), {
      'stats.connectionsCount': FieldValue.increment(1)
    });
    
    await batch.commit();
  }

  @override
  Future<void> rejectConnectionRequest(String requestId) {
     // Implementation similar to delete request
      throw UnimplementedError();
  }
  
  Future<void> removeRequest(String currentUserId, String fromUserId) async {
    await _firestore
        .collection('connection_requests')
        .doc(currentUserId)
        .collection('requests')
        .doc(fromUserId)
        .delete();
  }

  @override
  Stream<List<Relationship>> getPendingRequests(String userId) {
    return _firestore
        .collection('connection_requests')
        .doc(userId)
        .collection('requests')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
             // Map to Relationship entity
             // We need to fetch user details separately usually, 
             // but for now we create a basic Relationship object
             return Relationship(
               id: doc.id, 
               followerId: doc.id, // The person who requested
               followingId: userId, // Me
               status: RelationshipStatus.pending,
               createdAt: (doc.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
               memberName: doc.data()['fromUserName'],
               memberAvatar: doc.data()['fromUserAvatar'],
             );
          }).toList();
        });
  }

  @override
  Future<Relationship?> getConnectionStatus(String currentUserId, String targetUserId) async {
     // Check friends
     final friendDoc = await _firestore
         .collection('connections')
         .doc(currentUserId)
         .collection('friends')
         .doc(targetUserId)
         .get();
         
     if (friendDoc.exists) {
       return Relationship(
         id: '${currentUserId}_$targetUserId',
         followerId: currentUserId,
         followingId: targetUserId,
         status: RelationshipStatus.accepted,
         createdAt: (friendDoc.data()?['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
       );
     }
     
     // Check if I sent a request
     final sentRequest = await _firestore
         .collection('connection_requests')
         .doc(targetUserId)
         .collection('requests')
         .doc(currentUserId)
         .get();
         
      if (sentRequest.exists) {
       return Relationship(
         id: '${currentUserId}_$targetUserId',
         followerId: currentUserId,
         followingId: targetUserId,
         status: RelationshipStatus.pending,
         createdAt: (sentRequest.data()?['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
       );
     }
     
     return null;
  }

  @override
  Future<String> uploadPostImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    final snapshot = await ref.putFile(file);
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  @override
  Stream<List<Relationship>> getConnections(String userId) {
     return _firestore
        .collection('connections')
        .doc(userId)
        .collection('friends')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
             return Relationship(
               id: doc.id, 
               followerId: doc.id, // Friend ID
               followingId: userId, // ME
               status: RelationshipStatus.accepted,
               createdAt: (doc.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
               memberName: doc.data()['friendName'],
               memberAvatar: doc.data()['friendAvatar'],
             );
          }).toList();
        });
  }

  @override
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }
}
