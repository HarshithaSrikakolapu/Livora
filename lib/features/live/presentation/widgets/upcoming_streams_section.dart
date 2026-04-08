import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/features/live/presentation/providers/live_providers.dart';
import 'stream_card.dart';

class UpcomingStreamsSection extends ConsumerWidget {
  const UpcomingStreamsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledStreamsAsync = ref.watch(scheduledStreamsProvider);

    return scheduledStreamsAsync.when(
      data: (streams) {
        if (streams.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: ColorPalette.softGrey),
                  const SizedBox(width: 8),
                  Text(
                    'UPCOMING STREAMS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ColorPalette.pureWhite,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
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
                  return StreamCard(stream: streams[index], isLive: false);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, st) => const SizedBox.shrink(),
    );
  }
}
