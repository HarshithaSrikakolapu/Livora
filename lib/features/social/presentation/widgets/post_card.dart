
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Livora/features/social/domain/entities/post.dart';
import 'package:Livora/features/social/presentation/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Livora/core/widgets/animated_widgets.dart';
import 'package:Livora/core/widgets/custom_card.dart';
import 'package:Livora/core/theme/color_palette.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String? currentUserId;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onUserTap;
  final VoidCallback? onMoreOptions;

  const PostCard({
    super.key,
    required this.post,
    this.currentUserId,
    this.onLike,
    this.onComment,
    this.onUserTap,
    this.onMoreOptions,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays < 1) {
      if (diff.inHours > 0) return '${diff.inHours}h';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m';
      return 'Just now';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }
    return DateFormat('MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLiked = currentUserId != null && post.likedBy.contains(currentUserId);
    final primaryColor = theme.colorScheme.primary;

    return CustomCard(
      padding: EdgeInsets.zero, // Handle padding internally
      onTap: null, // Not clickable as a whole, but contains clickable elements
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                UserAvatar(
                  avatarUrl: post.userAvatar,
                  userName: post.userName,
                  radius: 20,
                  onTap: onUserTap,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: onUserTap,
                        child: Text(
                          post.userName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz_rounded, color: theme.iconTheme.color?.withOpacity(0.6)),
                  onPressed: onMoreOptions,
                ),
              ],
            ),
          ),
          
          // Content (Text)
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                post.caption,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            
          // Content (Image)
          if (post.mediaUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                 // Full screen view logic can be added here
              },
              child: CachedNetworkImage(
                imageUrl: post.mediaUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_rounded, size: 40, color: ColorPalette.softGrey),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 8),

          // Footer (Actions)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                _ActionButton(
                  icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: post.likesCount > 0 ? '${post.likesCount}' : 'Like',
                  color: isLiked ? ColorPalette.livoraRed : theme.iconTheme.color?.withOpacity(0.7),
                  onTap: onLike,
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: post.commentsCount > 0 ? '${post.commentsCount}' : 'Comment',
                  onTap: onComment,
                  color: theme.iconTheme.color?.withOpacity(0.7),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.share_rounded, size: 20, color: theme.iconTheme.color?.withOpacity(0.7)),
                  onPressed: () {
                    Share.share('Check out this post from ${post.userName}: ${post.caption}');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              label, 
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
