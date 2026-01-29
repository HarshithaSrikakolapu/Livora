
import 'package:edirectory_app/features/social/presentation/widgets/post_card.dart';
import '../../../../core/widgets/animated_widgets.dart'; // Import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/social_providers.dart';
import 'package:edirectory_app/features/auth/presentation/providers/firebase_auth_notifier.dart'; // Import
import 'package:edirectory_app/features/auth/presentation/providers/auth_state.dart'; // Import
import 'create_post_screen.dart';
import 'activity_screen.dart';
import 'user_profile_screen.dart'; // Import this for navigation
import 'connections_screen.dart'; // Import
import '../widgets/comments_sheet.dart'; // Import
import '../../../../core/theme/color_palette.dart'; // Import

class SocialFeedScreen extends ConsumerWidget {
  const SocialFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(globalFeedStreamProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Community Feed', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_box_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.people_outline), // Connections
                onPressed: () {
                   Navigator.of(context).push(
                     MaterialPageRoute(builder: (context) => const ConnectionsScreen()),
                   );
                },
              ),
            ],
          ),
          
          feedAsync.when(
            data: (posts) {
              if (posts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feed_outlined, size: 64, color: ColorPalette.primary.withOpacity(0.5)),
                        SizedBox(height: 16),
                        Text('No posts yet.', style: TextStyle(color: ColorPalette.primary.withOpacity(0.7))),
                        Text('Be the first to share something!', style: TextStyle(color: ColorPalette.primary.withOpacity(0.7))),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    final authState = ref.watch(firebaseAuthNotifierProvider);
                    
                    return ScaleFadeIn(
                      delay: Duration(milliseconds: 50 * (index % 10)),
                      child: PostCard(
                        post: post,
                        currentUserId: (authState is Authenticated) ? authState.user.id : null,
                        onLike: () {
                          // final authState = ref.read(firebaseAuthNotifierProvider); // Already watched above
                          if (authState is Authenticated) {
                            ref.read(toggleLikePostProvider).call(post.id, authState.user.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please login to like posts')),
                            );
                          }
                        },
                        onComment: () {
                           showModalBottomSheet(
                             context: context,
                             isScrollControlled: true,
                             shape: const RoundedRectangleBorder(
                               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                             ),
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
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.flag),
                                  title: const Text('Report Post'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post reported')));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
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
              child: Center(child: Text('Something went wrong: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
