import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/live/data/live_stream_service.dart';
import 'package:Livora/features/live/domain/entities/stream.dart';
import 'package:Livora/features/live/domain/entities/chat_message.dart';

final liveStreamServiceProvider = Provider<LiveStreamService>((ref) {
  return LiveStreamService();
});

final activeStreamsProvider = StreamProvider<List<LiveStream>>((ref) {
  final service = ref.watch(liveStreamServiceProvider);
  return service.getActiveStreams();
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, streamId) {
  final service = ref.watch(liveStreamServiceProvider);
  return service.getStreamChat(streamId);
});

final organizationStreamsProvider = StreamProvider.family<List<LiveStream>, String>((ref, orgId) {
  final service = ref.watch(liveStreamServiceProvider);
  return service.getOrganizationStreams(orgId);
});

final singleStreamProvider = StreamProvider.family<LiveStream?, String>((ref, streamId) {
  final service = ref.watch(liveStreamServiceProvider);
  return service.getStream(streamId);
});

final liveStreamsProvider = Provider<AsyncValue<List<LiveStream>>>((ref) {
  final activeAsync = ref.watch(activeStreamsProvider);
  
  return activeAsync.whenData((streams) {
    final now = DateTime.now();
    return streams.where((s) {
      if (s.status == StreamStatus.live) return true;
      if (s.status == StreamStatus.scheduled && s.scheduledAt != null) {
        return s.scheduledAt!.isBefore(now);
      }
      return false;
    }).toList();
  });
});

final scheduledStreamsProvider = Provider<AsyncValue<List<LiveStream>>>((ref) {
  final activeAsync = ref.watch(activeStreamsProvider);
  
  return activeAsync.whenData((streams) {
    final now = DateTime.now();
    return streams.where((s) {
      return s.status == StreamStatus.scheduled && 
             (s.scheduledAt == null || s.scheduledAt!.isAfter(now));
    }).toList();
  });
});

class GoLiveNotifier extends StateNotifier<AsyncValue<void>> {
  final LiveStreamService _service;

  GoLiveNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> startStream({
    required String creatorId,
    required String title,
    required PlatformType platform,
    required String url,
    required String category,
    DateTime? scheduledAt,
    bool chatEnabled = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final streamId = DateTime.now().millisecondsSinceEpoch.toString();
      final stream = LiveStream(
        id: streamId,
        creatorId: creatorId,
        platformType: platform,
        streamUrl: url,
        title: title,
        status: scheduledAt == null ? StreamStatus.live : StreamStatus.scheduled,
        startedAt: DateTime.now(),
        scheduledAt: scheduledAt,
        viewerCount: 0,
        totalViews: 0,
        chatEnabled: chatEnabled,
        category: category,
      );

      await _service.createStream(stream);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> stopStream(String streamId) async {
    state = const AsyncValue.loading();
    try {
      await _service.endStream(streamId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteStream(String streamId) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteStream(streamId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final goLiveNotifierProvider = StateNotifierProvider<GoLiveNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(liveStreamServiceProvider);
  return GoLiveNotifier(service);
});
