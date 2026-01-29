
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/color_palette.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String userName; // For initials if avatar is null
  final double radius;
  final bool enableHero;
  final VoidCallback? onTap;

  const UserAvatar({
    Key? key,
    this.avatarUrl,
    required this.userName,
    this.radius = 20,
    this.enableHero = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate initials (first letter of first and last name ideally, but simple for now)
    final initials = userName.isNotEmpty 
        ? userName.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join() 
        : '?';

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: ColorPalette.lightGrey,
      backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
          ? CachedNetworkImageProvider(avatarUrl!)
          : null,
      child: (avatarUrl == null || avatarUrl!.isEmpty)
          ? Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
                color: ColorPalette.primary,
              ),
            )
          : null,
    );
    
    // Add Hero if enabled and URL is present (or name for uniqueness, but typically URL)
    if (enableHero && avatarUrl != null) {
      avatar = Hero(
        tag: 'avatar_$avatarUrl',
        child: avatar,
      );
    }
    
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}
