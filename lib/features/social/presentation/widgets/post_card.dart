
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edirectory_app/features/social/domain/entities/post.dart';
import 'package:edirectory_app/features/social/presentation/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/theme/color_palette.dart'; 

class PostCard extends StatelessWidget {
  final Post post;
  final String? currentUserId;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onUserTap;
  final VoidCallback? onMoreOptions;

  const PostCard({
    Key? key,
    required this.post,
    this.currentUserId,
    this.onLike,
    this.onComment,
    this.onUserTap,
    this.onMoreOptions,
  }) : super(key: key);

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: UserAvatar(
              avatarUrl: post.userAvatar,
              userName: post.userName,
              onTap: onUserTap,
            ),
            title: Text(
              post.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, color: ColorPalette.primary),
            ),
            subtitle: Text(_formatDate(post.createdAt), style: TextStyle(color: ColorPalette.primary.withOpacity(0.6))),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz, color: ColorPalette.primary),
              onPressed: onMoreOptions,
            ),
          ),
          
          // Content (Text)
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                post.caption,
                style: const TextStyle(fontSize: 15, color: ColorPalette.primary),
              ),
            ),
            
          // Content (Image)
          if (post.mediaUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                 // Full screen view
              },
              child: CachedNetworkImage(
                imageUrl: post.mediaUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: ColorPalette.lightGrey,
                  child: const Center(child: CircularProgressIndicator(color: ColorPalette.primary)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: ColorPalette.lightGrey,
                  child: const Icon(Icons.error, color: ColorPalette.primary),
                ),
              ),
            ),
          ],
          
          // Footer (Actions)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 24, color: ColorPalette.divider),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Row(
              children: [
                _ActionButton(
                  icon: (currentUserId != null && post.likedBy.contains(currentUserId)) 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  label: post.likesCount > 0 ? '${post.likesCount}' : 'Like',
                  color: (currentUserId != null && post.likedBy.contains(currentUserId)) 
                      ? ColorPalette.primary 
                      : null,
                  onTap: onLike,
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: post.commentsCount > 0 ? '${post.commentsCount}' : 'Comment',
                  onTap: onComment,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share, size: 20, color: ColorPalette.primary),
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
    final defaultColor = ColorPalette.primary;
    final displayColor = color ?? defaultColor;
    
    return AnimatedScaleButton(
      onTap: onTap ?? () {},
      child: InkWell(
        onTap: null, // Handled by AnimatedScaleButton
        child: Row(
          children: [
            Icon(icon, size: 20, color: displayColor),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: displayColor)),
          ],
        ),
      ),
    );
  }
}
