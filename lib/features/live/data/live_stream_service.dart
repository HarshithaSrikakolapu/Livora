import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Livora/features/live/domain/entities/stream.dart';
import 'package:Livora/features/live/domain/entities/chat_message.dart';

class LiveStreamService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'streams';

  /// Create a new stream record in Firestore
  Future<void> createStream(LiveStream stream) async {
    await _db.collection('streams').doc(stream.id).set(stream.toFirestore());
  }

  /// Get all active (live or scheduled) streams
  Stream<List<LiveStream>> getActiveStreams() {
    return _db.collection('streams')
        .where('status', whereIn: ['live', 'scheduled'])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LiveStream.fromFirestore(doc)).toList());
  }

  /// Get a list of currently live streams
  Stream<List<LiveStream>> getLiveStreams() {
    return _db.collection('streams')
        .where('status', isEqualTo: 'live')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LiveStream.fromFirestore(doc)).toList());
  }

  /// Get a list of scheduled streams
  Stream<List<LiveStream>> getScheduledStreams() {
    return _db.collection('streams')
        .where('status', isEqualTo: 'scheduled')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LiveStream.fromFirestore(doc)).toList());
  }

  /// End a stream by updating its status and end time
  Future<void> endStream(String streamId) async {
    await _db.collection('streams').doc(streamId).update({
      'status': 'ended',
      'ended_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update the status of a stream
  Future<void> updateStreamStatus(String streamId, StreamStatus status) async {
    await _db.collection(_collectionPath).doc(streamId).update({
      'status': status.name,
      if (status == StreamStatus.live) 'started_at': FieldValue.serverTimestamp(),
    });
  }

  /// Increment viewer count when a user joins
  Future<void> joinStream(String streamId, String userId) async {
    try {
      debugPrint('LIVE SERVICE: Joining stream $streamId (User: $userId)');
      
      final viewerRef = _db.collection(_collectionPath)
          .doc(streamId)
          .collection('viewers')
          .doc(userId);
          
      final viewerDoc = await viewerRef.get();
      
      if (!viewerDoc.exists) {
        // First time viewing - increment total and current
        await _db.runTransaction((transaction) async {
          final streamRef = _db.collection(_collectionPath).doc(streamId);
          transaction.update(streamRef, {
            'viewer_count': FieldValue.increment(1),
            'total_views': FieldValue.increment(1),
          });
          transaction.set(viewerRef, {
            'timestamp': FieldValue.serverTimestamp(),
          });
        });
      } else {
        // Returning viewer - only increment current count
        await _db.collection(_collectionPath).doc(streamId).update({
          'viewer_count': FieldValue.increment(1),
        });
      }
      
      debugPrint('LIVE SERVICE: joinStream success');
    } catch (e) {
      debugPrint('LIVE SERVICE ERROR: joinStream failed for $streamId: $e');
    }
  }

  /// Decrement viewer count when a user leaves
  Future<void> leaveStream(String streamId) async {
    try {
      debugPrint('LIVE SERVICE: Leaving stream $streamId');
      await _db.collection(_collectionPath).doc(streamId).update({
        'viewer_count': FieldValue.increment(-1),
      });
      debugPrint('LIVE SERVICE: leaveStream success');
    } catch (e) {
      debugPrint('LIVE SERVICE ERROR: leaveStream failed for $streamId: $e');
    }
  }

  /// Get real-time chat messages for a stream
  Stream<List<ChatMessage>> getStreamChat(String streamId) {
    return _db.collection(_collectionPath)
        .doc(streamId)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  /// Send a chat message
  Future<void> sendChatMessage(String streamId, ChatMessage message) async {
    await _db.collection(_collectionPath)
        .doc(streamId)
        .collection('chat')
        .add(message.toFirestore());
  }

  /// Permanently remove a stream record
  Future<void> deleteStream(String streamId) async {
    await _db.collection(_collectionPath).doc(streamId).delete();
  }

  /// Get all streams for a specific organization
  Stream<List<LiveStream>> getOrganizationStreams(String orgId) {
    return _db.collection(_collectionPath)
        .where('creator_id', isEqualTo: orgId)
        .snapshots()
        .map((snapshot) {
          final streams = snapshot.docs.map((doc) => LiveStream.fromFirestore(doc)).toList();
          // Sort in-memory to avoid needing a Firestore composite index
          streams.sort((a, b) => b.startedAt.compareTo(a.startedAt));
          return streams;
        });
  }

  /// Get real-time updates for a single stream
  Stream<LiveStream?> getStream(String streamId) {
    return _db.collection(_collectionPath)
        .doc(streamId)
        .snapshots()
        .map((doc) => doc.exists ? LiveStream.fromFirestore(doc) : null);
  }
}
