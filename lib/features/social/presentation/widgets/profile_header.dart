
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edirectory_app/features/social/presentation/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_palette.dart'; 

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String? bio;
  final Map<String, int> stats;
  final Widget? actionButton;

  const ProfileHeader({
    Key? key,
    required this.userName,
    this.avatarUrl,
    this.coverImageUrl,
    this.bio,
    this.stats = const {},
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cover Height
    const double coverHeight = 160;
    const double avatarRadius = 45;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomLeft,
          children: [
            // Cover Image
            Container(
              height: coverHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorPalette.secondary, 
                image: (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(coverImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: coverImageUrl == null
                  ? Center(child: Icon(Icons.camera_alt, color: ColorPalette.primary.withOpacity(0.5)))
                  : null,
            ),
            
            // Avatar (Overlapping)
            Positioned(
              bottom: -(avatarRadius * 0.4),
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                ),
                child: UserAvatar(
                  userName: userName,
                  avatarUrl: avatarUrl,
                  radius: avatarRadius,
                  enableHero: true,
                ),
              ),
            ),
          ],
        ),
        
        // Info Section
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (actionButton != null) actionButton!,
                ],
              ),
              // If no action button, add spacing so name doesn't hit top abruptly if avatar is big? 
              // Actually avatar overlaps, so name starts below cover.
              // But avatar takes left space. 
              const SizedBox(height: 10),
              
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              
              if (bio != null && bio!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(bio!),
              ],
              
              const SizedBox(height: 16),
              
              // Stats
              Row(
                children: [
                  _StatItem(label: 'Posts', value: '${stats['postsCount'] ?? 0}'),
                  const SizedBox(width: 20),
                  _StatItem(label: 'Connections', value: '${stats['connectionsCount'] ?? 0}'),
                ],
              ),
            ],
          ),
        ),
        const Divider(thickness: 1, height: 1),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
