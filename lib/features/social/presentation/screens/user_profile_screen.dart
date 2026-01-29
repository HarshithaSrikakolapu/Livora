
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/relationship.dart';
import '../../../auth/domain/entities/user.dart'; // Import User
import '../providers/social_providers.dart';
import '../../domain/usecases/toggle_like_post.dart'; // Import
import '../widgets/profile_header.dart';
import '../widgets/post_card.dart';
import '../widgets/comments_sheet.dart'; // Import
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import 'edit_profile_screen.dart'; 
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/theme/color_palette.dart'; // Import

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserState = ref.watch(firebaseAuthNotifierProvider);
    final isMe = (currentUserState is Authenticated && currentUserState.user.id == userId);
    
    final userProfileAsync = ref.watch(userProfileFutureProvider(userId));
    final postsAsync = ref.watch(userPostsStreamProvider(userId));
    final connectionStatusAsync = isMe ? const AsyncValue.data(null) : ref.watch(connectionStatusProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(isMe ? 'My Profile' : 'Profile'),
        centerTitle: true,
      ),
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          
          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: FadeInUp(
                  child: ProfileHeader(
                    userName: user.fullName,
                    avatarUrl: user.avatarUrl,
                    coverImageUrl: user.coverImageUrl,
                    bio: user.bio,
                    stats: user.stats,
                    actionButton: isMe 
                        ? AnimatedScaleButton(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                              );
                            },
                            child: OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                            ),
                          )
                        : connectionStatusAsync.when( // Show Connect button only if NOT me
                            data: (relationship) {
                                if (relationship == null) {
                                return AnimatedScaleButton(
                                  onTap: () async {
                                    if (currentUserState is Authenticated) {
                                       await ref.read(sendConnectionRequestProvider).call(
                                         currentUserState.user.id,
                                         currentUserState.user.fullName,
                                         currentUserState.user.avatarUrl,
                                         userId
                                       );
                                       ref.invalidate(connectionStatusProvider(userId));
                                    }
                                  },
                                  child: FilledButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.person_add),
                                    label: const Text('Connect'),
                                  ),
                                );
                              } else if (relationship.status == RelationshipStatus.pending) {
                                if (relationship.followerId == (currentUserState as Authenticated).user.id) {
                                  return OutlinedButton.icon(
                                    onPressed: null, 
                                    icon: const Icon(Icons.hourglass_empty),
                                    label: const Text('Requested'),
                                  );
                                } else {
                                  return AnimatedScaleButton(
                                    onTap: () async {
                                       await ref.read(acceptConnectionRequestProvider).call(currentUserState.user.id, userId);
                                       ref.invalidate(connectionStatusProvider(userId));
                                    },
                                    child: FilledButton.icon(
                                      onPressed: null,
                                      icon: const Icon(Icons.check),
                                      label: const Text('Accept'),
                                    ),
                                  );
                                }
                              } else if (relationship.status == RelationshipStatus.accepted) {
                                return OutlinedButton.icon(
                                  onPressed: () {
                                     // TODO: Message/Unfriend
                                  },
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Connected'),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (_,__) => const SizedBox.shrink(),
                          ),
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: Divider()),
              
              // Posts
              postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('No posts yet', style: TextStyle(color: ColorPalette.textSecondary))),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ScaleFadeIn(
                        delay: Duration(milliseconds: 50 * (index % 10)),
                        child: PostCard(
                          post: posts[index],
                          currentUserId: (currentUserState is Authenticated) ? currentUserState.user.id : null,
                          onLike: () {
                            if (currentUserState is Authenticated) {
                              ref.read(toggleLikePostProvider).call(posts[index].id, currentUserState.user.id);
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
                               builder: (context) => CommentsSheet(postId: posts[index].id),
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
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      childCount: posts.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading profile: $e')),
      ),
    );
  }
}
