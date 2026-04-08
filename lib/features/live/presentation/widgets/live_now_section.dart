import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/features/live/presentation/providers/live_providers.dart';
import 'package:Livora/features/live/presentation/screens/live_player_screen.dart';
import 'package:Livora/features/live/domain/entities/stream.dart';
import 'stream_card.dart';

class LiveNowSection extends ConsumerWidget {
  const LiveNowSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveStreamsAsync = ref.watch(liveStreamsProvider);

    return liveStreamsAsync.when(
      data: (streams) {
        // Sync scheduled streams that have passed their time back to Firestore
        final now = DateTime.now();
        for (final s in streams) {
          if (s.status == StreamStatus.scheduled && 
              s.scheduledAt != null && 
              s.scheduledAt!.isBefore(now)) {
            ref.read(liveStreamServiceProvider).updateStreamStatus(s.id, StreamStatus.live);
          }
        }

        debugPrint('LIVE: Received ${streams.length} live streams');
        if (streams.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.emergency_recording_rounded, color: ColorPalette.livoraRed),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE NOW',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ColorPalette.pureWhite,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All', style: TextStyle(color: ColorPalette.softGrey)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: streams.length,
                itemBuilder: (context, index) {
                  return StreamCard(stream: streams[index], isLive: true);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: ColorPalette.livoraRed)),
      ),
      error: (err, st) {
        debugPrint('LIVE ERROR: $err');
        return const SizedBox.shrink();
      },
    );
  }
}
