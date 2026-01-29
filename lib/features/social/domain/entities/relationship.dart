
import 'package:cloud_firestore/cloud_firestore.dart';

enum RelationshipStatus { pending, accepted, declined }

class Relationship {
  final String id;
  final String followerId;
  final String followingId;
  final RelationshipStatus status;
  final DateTime createdAt;
  
  // Denormalized data for display
  final String? memberName;
  final String? memberAvatar;

  Relationship({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.status,
    required this.createdAt,
    this.memberName,
    this.memberAvatar,
  });

  factory Relationship.fromFirestore(Map<String, dynamic> data, String id) {
    return Relationship(
      id: id,
      followerId: data['followerId'] ?? data['fromUserId'] ?? '', // Handle different schema conventions
      followingId: data['followingId'] ?? '',
      status: RelationshipStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => RelationshipStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberName: data['memberName'] ?? data['fromUserName'],
      memberAvatar: data['memberAvatar'] ?? data['fromUserAvatar'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'followerId': followerId,
      'followingId': followingId,
      'status': status.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
      'memberName': memberName,
      'memberAvatar': memberAvatar,
    };
  }
}
