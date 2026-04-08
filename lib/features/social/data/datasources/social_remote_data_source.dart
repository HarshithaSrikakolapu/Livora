
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:Livora/features/social/domain/entities/post.dart';
import 'package:Livora/features/social/domain/entities/comment.dart';
import 'package:Livora/features/social/domain/entities/relationship.dart';

abstract class SocialRemoteDataSource {
  Future<void> removeConnection(String currentUserId, String targetUserId);
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId, String userId);
  Future<void> addComment(String postId, String text, String userId, String userName, String? userAvatar);
  Stream<List<Comment>> getComments(String postId);
  Stream<List<Post>> getGlobalFeed({int limit = 20});
  Stream<List<Post>> getUserPosts(String userId);
  
  Future<void> sendConnectionRequest(String currentUserId, String userName, String? userAvatar, String targetUserId);
  Future<void> acceptConnectionRequest(String requestId);
  Future<void> rejectConnectionRequest(String requestId);
  Stream<List<Relationship>> getPendingRequests(String userId);
  Future<Relationship?> getConnectionStatus(String currentUserId, String targetUserId);
  
  Future<String> uploadPostImage(Uint8List data, String fileName);
  
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
Future<void> removeConnection(String currentUserId, String targetUserId) async {
  final query = await _firestore
      .collection('relationships')
      .where('followerId', isEqualTo: currentUserId)
      .where('followingId', isEqualTo: targetUserId)
      .get();

  for (var doc in query.docs) {
    await doc.reference.delete();
  }
}
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
    data['createdAt'] = FieldValue.serverTimestamp();
    
    await docRef.set(data);
    
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
      await userLikeRef.delete();
      await postRef.update({
        'likesCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
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
        .orderBy('createdAt', descending: false)
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

  @override
  Future<void> sendConnectionRequest(String currentUserId, String userName, String? userAvatar, String targetUserId) async {
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
    throw UnimplementedError('Use acceptRequest instead');
  }
  
  Future<void> acceptRequest(String currentUserId, String fromUserId) async {
    final batch = _firestore.batch();
    
    final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
    final fromUserDoc = await _firestore.collection('users').doc(fromUserId).get();
    
    final currentUserName = currentUserDoc.data()?['fullName'];
    final currentUserAvatar = currentUserDoc.data()?['avatarUrl'];
    
    final fromUserName = fromUserDoc.data()?['fullName'];
    final fromUserAvatar = fromUserDoc.data()?['avatarUrl'];
    
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
    
    final requestRef = _firestore
        .collection('connection_requests')
        .doc(currentUserId)
        .collection('requests')
        .doc(fromUserId);
        
    batch.delete(requestRef);
    
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
             return Relationship(
               id: doc.id, 
               followerId: doc.id,
               followingId: userId,
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
  Future<String> uploadPostImage(Uint8List data, String fileName) async {
    final ref = _storage.ref().child('posts/$fileName');
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final snapshot = await ref.putData(data, metadata);
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
               followerId: doc.id,
               followingId: userId,
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
    print('Firestore: Updating user profile for $userId');
    await _firestore.collection('users').doc(userId).update(data);
  }
}

