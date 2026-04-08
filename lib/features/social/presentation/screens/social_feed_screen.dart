
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/social/presentation/widgets/post_card.dart';
import 'package:Livora/core/widgets/animated_widgets.dart'; 
import 'package:Livora/features/social/presentation/providers/social_providers.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'create_post_screen.dart';
import 'user_profile_screen.dart';
import 'connections_screen.dart';
import 'package:Livora/features/social/presentation/widgets/comments_sheet.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'dart:ui'; // For blur

class SocialFeedScreen extends ConsumerWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(globalFeedStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: theme.colorScheme.surface.withOpacity(0.8)),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Community Feed', 
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.people_alt_rounded, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ConnectionsScreen()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: FloatingActionButton.small(
              heroTag: 'create_post',
              elevation: 4,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Add some top padding for the transparent app bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
          
          feedAsync.when(
            data: (posts) {
              if (posts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: FadeInUp(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.feed_outlined, size: 80, color: theme.disabledColor),
                          const SizedBox(height: 16),
                          Text(
                            'No posts yet',
                             style: theme.textTheme.titleLarge?.copyWith(
                               color: theme.disabledColor,
                               fontWeight: FontWeight.bold
                             ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to share something!', 
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.disabledColor
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    final authState = ref.watch(firebaseAuthNotifierProvider);
                    
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: FadeInUp(
                        delay: Duration(milliseconds: 50 * (index % 5)), // Cap delay
                        child: PostCard(
                          post: post,
                          currentUserId: (authState is Authenticated) ? authState.user.id : null,
                          onLike: () {
                            if (authState is Authenticated) {
                              ref.read(toggleLikePostProvider).call(post.id, authState.user.id);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Please login to like posts'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            }
                          },
                          onComment: () {
                             showModalBottomSheet(
                               context: context,
                               isScrollControlled: true,
                               backgroundColor: Colors.transparent,
                               builder: (context) => CommentsSheet(postId: post.id),
                             );
                          },
                          onUserTap: () {
                             Navigator.of(context).push(
                               MaterialPageRoute(
                                 builder: (context) => UserProfileScreen(userId: post.userId),
                               ),
                             );
                          },
                          onMoreOptions: () {
                            // TODO: Modernize bottom sheet
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.flag_rounded, color: Colors.orange),
                                      title: const Text('Report Post'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post reported')));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  childCount: posts.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Something went wrong. Pull to refresh.')),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom nav space
        ],
      ),
    );
  }
}
