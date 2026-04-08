import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/features/live/presentation/providers/live_providers.dart';
import 'package:Livora/features/live/presentation/screens/live_player_screen.dart';
import 'package:Livora/features/live/domain/entities/stream.dart';

class StreamCard extends StatelessWidget {
  final LiveStream stream;
  final bool isLive;

  const StreamCard({
    super.key, 
    required this.stream,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LivePlayerScreen(stream: stream),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: ColorPalette.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorPalette.borderSubtle, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Bottom Info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stream.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isLive)
                        Row(
                          children: [
                            // Current Live
                            const Icon(Icons.circle, size: 8, color: ColorPalette.livoraRed),
                            const SizedBox(width: 4),
                            Text(
                              '${stream.viewerCount}',
                              style: const TextStyle(
                                color: ColorPalette.livoraRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Total Views
                            const Icon(Icons.visibility, size: 10, color: ColorPalette.softGrey),
                            const SizedBox(width: 4),
                            Text(
                              '${stream.totalViews}',
                              style: const TextStyle(color: ColorPalette.softGrey, fontSize: 10),
                            ),
                          ],
                        )
                      else if (stream.scheduledAt != null)
                        Text(
                          '${stream.scheduledAt!.hour}:${stream.scheduledAt!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: ColorPalette.softGrey, fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLive ? ColorPalette.livoraRed : ColorPalette.softGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isLive ? 'LIVE' : 'UPCOMING',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Avatar Placeholder (Center Icon)
              const Center(
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: ColorPalette.darkSurface,
                  child: Icon(Icons.person, color: ColorPalette.softGrey, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
