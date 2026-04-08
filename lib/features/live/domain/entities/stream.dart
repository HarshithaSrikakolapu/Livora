import 'package:cloud_firestore/cloud_firestore.dart';

enum StreamStatus { live, scheduled, ended }

enum PlatformType { facebook, youtube, livora }

class LiveStream {
  final String id;
  final String creatorId;
  final PlatformType platformType;
  final String streamUrl;
  final String title;
  final StreamStatus status;
  final DateTime startedAt;
  final DateTime? scheduledAt;
  final int viewerCount;
  final int totalViews;
  final bool chatEnabled;
  final String category;

  LiveStream({
    required this.id,
    required this.creatorId,
    required this.platformType,
    required this.streamUrl,
    required this.title,
    required this.status,
    required this.startedAt,
    this.scheduledAt,
    required this.viewerCount,
    required this.totalViews,
    this.chatEnabled = true,
    this.category = 'Church',
  });

  factory LiveStream.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LiveStream(
      id: doc.id,
      creatorId: data['creator_id'] ?? '',
      platformType: _parsePlatformType(data['platform_type']),
      streamUrl: data['stream_url'] ?? '',
      title: data['title'] ?? '',
      status: _parseStatus(data['status']),
      startedAt: (data['started_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledAt: (data['scheduled_at'] as Timestamp?)?.toDate(),
      viewerCount: data['viewer_count'] ?? 0,
      totalViews: data['total_views'] ?? 0,
      chatEnabled: data['chat_enabled'] ?? true,
      category: data['category'] ?? 'Church',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'creator_id': creatorId,
      'platform_type': platformType.name,
      'stream_url': streamUrl,
      'title': title,
      'status': status.name,
      'started_at': Timestamp.fromDate(startedAt),
      'scheduled_at': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'viewer_count': viewerCount,
      'total_views': totalViews,
      'chat_enabled': chatEnabled,
      'category': category,
    };
  }

  static StreamStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'live':
        return StreamStatus.live;
      case 'scheduled':
        return StreamStatus.scheduled;
      case 'ended':
        return StreamStatus.ended;
      default:
        return StreamStatus.ended;
    }
  }

  static PlatformType _parsePlatformType(String? type) {
    switch (type?.toLowerCase()) {
      case 'facebook':
        return PlatformType.facebook;
      case 'youtube':
        return PlatformType.youtube;
      case 'livora':
        return PlatformType.livora;
      default:
        return PlatformType.livora;
    }
  }
}
