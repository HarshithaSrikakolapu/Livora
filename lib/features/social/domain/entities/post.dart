
import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { image, video, reel }

class Post {
  final String id;
  final String userId;
  final String userName; // Denormalized for ease
  final String? userAvatar; // Denormalized
  final PostType type;
  final String mediaUrl;
  final String? thumbnailUrl; // For video/reels
  final String caption;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final List<String> likedBy; // List of user IDs who liked it

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.type,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.caption = '',
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.likedBy = const [],
  });

  factory Post.fromFirestore(Map<String, dynamic> data, String id) {
    return Post(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userAvatar: data['userAvatar'],
      type: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.${data['type']}',
        orElse: () => PostType.image,
      ),
      mediaUrl: data['mediaUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      caption: data['caption'] ?? '',
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'type': type.toString().split('.').last, // Store as string 'image', 'video'
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': FieldValue.serverTimestamp(),
      'likedBy': likedBy,
    };
  }
}
