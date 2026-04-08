
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/social/domain/entities/post.dart';
import 'package:Livora/features/social/domain/entities/relationship.dart';
import 'package:Livora/features/auth/domain/entities/user.dart';
import 'package:Livora/features/social/presentation/providers/social_providers.dart';
import 'package:Livora/features/social/domain/usecases/toggle_like_post.dart';
import 'package:Livora/features/social/presentation/widgets/profile_header.dart';
import 'package:Livora/features/social/presentation/widgets/post_card.dart';
import 'package:Livora/features/social/presentation/widgets/comments_sheet.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:Livora/core/widgets/animated_widgets.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/features/social/presentation/providers/social_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUserState = ref.watch(firebaseAuthNotifierProvider);
    final isMe = (currentUserState is Authenticated && currentUserState.user.id == userId);
    final isAdmin = (currentUserState is Authenticated && currentUserState.user.role == 'superAdmin');
    final canEdit = isMe || isAdmin;
    
    final userProfileAsync = ref.watch(userProfileFutureProvider(userId));
    final postsAsync = ref.watch(userPostsStreamProvider(userId));
    final connectionStatusAsync = isMe ? const AsyncValue.data(null) : ref.watch(connectionStatusProvider(userId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_rounded, size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text('User not found', style: theme.textTheme.titleLarge),
                ],
              ),
            );
          }
          
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Glass App Bar
              SliverAppBar(
                expandedHeight: 0, // Collapsed mainly, acts as sticker
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                title: Text(
                  isMe ? 'My Profile' : user.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),

              // Wrapper for content padding
              SliverToBoxAdapter(child: SizedBox(height: 16)), // Padding from top since AppBar is pinned and transparent-ish

              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FadeInUp(
                    child: ProfileHeader(
                      userName: user.fullName,
                      avatarUrl: user.avatarUrl,
                      coverImageUrl: user.coverImageUrl,
                      bio: user.bio,
                      stats: user.stats,
                      actionButton: canEdit 
                          ? _buildEditButton(context)
                          : _buildConnectionButton(ref, context, userId, currentUserState, connectionStatusAsync),
                    ),
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: Divider(thickness: 1),
  ),
),
              
              // Posts Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'Posts',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Posts List
              postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.dashboard_customize_outlined, size: 48, color: theme.disabledColor.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'No posts yet',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.disabledColor,
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
                      (context, index) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: ScaleFadeIn(
                          delay: Duration(milliseconds: 50 * (index % 5)),
                          child: PostCard(
                            post: posts[index],
                            currentUserId: (currentUserState is Authenticated) ? currentUserState.user.id : null,
                            onLike: () {
                              if (currentUserState is Authenticated) {
                                ref.read(toggleLikePostProvider).call(posts[index].id, currentUserState.user.id);
                              } else {
                                _showLoginSnack(context);
                              }
                            },
                            onComment: () => _showComments(context, posts[index].id),
                            onMoreOptions: () => _showPostOptions(context),
                          ),
                        ),
                      ),
                      childCount: posts.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading profile')),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
        },
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text('Edit Profile'),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildConnectionButton(
    WidgetRef ref, 
    BuildContext context, 
    String userId, 
    AuthState currentUserState, 
    AsyncValue<Relationship?> connectionStatusAsync
  ) {
    return connectionStatusAsync.when(
      data: (relationship) {
          if (relationship == null) {
          return FilledButton.icon(
            onPressed: () async {
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
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Connect'),
             style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        } else if (relationship.status == RelationshipStatus.pending) {
          if (relationship.followerId == (currentUserState as Authenticated).user.id) {
            return OutlinedButton.icon(
              onPressed: null, 
              icon: const Icon(Icons.hourglass_top_rounded, size: 18),
              label: const Text('Requested'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          } else {
            return FilledButton.icon(
              onPressed: () async {
                 await ref.read(acceptConnectionRequestProvider).call(currentUserState.user.id, userId);
                 ref.invalidate(connectionStatusProvider(userId));
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Accept'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }
        } else if (relationship.status == RelationshipStatus.accepted) {
  return OutlinedButton.icon(
    onPressed: () async {
      print("Remove clicked");
  if (currentUserState is Authenticated) {
    await ref.read(removeConnectionProvider)
        .call(currentUserState.user.id, userId);

    ref.refresh(connectionStatusProvider(userId));
  }
},

    icon: const Icon(Icons.person_remove_rounded, size: 18),
    label: const Text('Remove Connection'),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.red,
      side: const BorderSide(color: Colors.red),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox(
        width: 24, height: 24, 
        child: CircularProgressIndicator(strokeWidth: 2)
      ),
      error: (_,__) => const SizedBox.shrink(),
    );
  }

  void _showLoginSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please login to interact')),
    );
  }

  void _showComments(BuildContext context, String postId) {
     showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       backgroundColor: Colors.transparent,
       builder: (context) => CommentsSheet(postId: postId),
     );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: ColorPalette.borderSubtle, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.flag_rounded, color: ColorPalette.softGrey),
              title: const Text('Report Post'),
              onTap: () {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post reported')));
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }
}
