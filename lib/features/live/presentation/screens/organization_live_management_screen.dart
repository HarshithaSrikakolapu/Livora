import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/live/presentation/providers/live_providers.dart';
import 'package:Livora/features/live/domain/entities/stream.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/core/widgets/animated_widgets.dart';

class OrganizationLiveManagementScreen extends ConsumerWidget {
  final String organizationId;
  const OrganizationLiveManagementScreen({super.key, required this.organizationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamsAsync = ref.watch(organizationStreamsProvider(organizationId));

    return Scaffold(
      backgroundColor: ColorPalette.darkBackground,
      appBar: AppBar(
        title: const Text('Manage Live Streams'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: streamsAsync.when(
        data: (streams) {
          final activeStreams = streams.where((s) => s.status != StreamStatus.ended).toList();
          
          if (activeStreams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off_outlined, color: ColorPalette.softGrey, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'No active or scheduled streams.',
                    style: TextStyle(color: ColorPalette.softGrey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeStreams.length,
            itemBuilder: (context, index) {
              final stream = activeStreams[index];
              return _buildStreamCard(context, ref, stream);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildStreamCard(BuildContext context, WidgetRef ref, LiveStream stream) {
    bool isLive = stream.status == StreamStatus.live;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? ColorPalette.livoraRed.withOpacity(0.5) : ColorPalette.softGrey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLive ? ColorPalette.livoraRed : Colors.blueGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stream.status.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
              Text(
                '${stream.viewerCount} watching',
                style: const TextStyle(color: ColorPalette.softGrey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stream.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'URL: ${stream.streamUrl}',
            style: const TextStyle(color: ColorPalette.softGrey, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (isLive)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStopDialog(context, ref, stream),
                    icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
                    label: const Text('STOP STREAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.livoraRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              if (stream.status == StreamStatus.scheduled)
                 Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(ref, stream, StreamStatus.live),
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                    label: const Text('GO LIVE NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline, color: ColorPalette.softGrey),
                onPressed: () => _showDeleteDialog(context, ref, stream),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStopDialog(BuildContext context, WidgetRef ref, LiveStream stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorPalette.darkSurface,
        title: const Text('Stop Live Stream', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to end this live stream?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              ref.read(liveStreamServiceProvider).endStream(stream.id);
              Navigator.pop(context);
            },
            child: const Text('STOP', style: TextStyle(color: ColorPalette.livoraRed)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, LiveStream stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorPalette.darkSurface,
        title: const Text('Remove Stream', style: TextStyle(color: Colors.white)),
        content: const Text('This will permanently delete the stream record. This cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              ref.read(goLiveNotifierProvider.notifier).deleteStream(stream.id);
              Navigator.pop(context);
            },
            child: const Text('REMOVE', style: TextStyle(color: ColorPalette.livoraRed)),
          ),
        ],
      ),
    );
  }

  void _updateStatus(WidgetRef ref, LiveStream stream, StreamStatus status) {
    ref.read(liveStreamServiceProvider).updateStreamStatus(stream.id, status);
  }
}
