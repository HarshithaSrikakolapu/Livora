import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import '../providers/profile_providers.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../social/presentation/screens/activity_screen.dart';
import 'favorite_orgs_screen.dart';
import '../../../../core/widgets/animated_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final authState = ref.watch(firebaseAuthNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(firebaseAuthNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: userProfileAsync.when(
        data: (profile) {
          if (profile == null) {
            // Ideally should not happen if authenticated, but maybe first time setup
            // Or if authState is not Authenticated yet
            if (authState is Authenticated) {
               // Fallback to basic auth user info if profile doc missing
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Text('Profile not found.'),
                     ElevatedButton(
                       onPressed: () {
                         // TODO: Create profile logic
                       },
                       child: const Text('Create Profile'),
                     ),
                   ],
                 ),
               );
            }
            return const Center(child: Text('Please log in.'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Avatar
                FadeInUp(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue[100],
                        backgroundImage: profile.profilePhoto != null 
                            ? NetworkImage(profile.profilePhoto!) 
                            : null,
                        child: profile.profilePhoto == null
                            ? Text(
                                profile.name.isNotEmpty ? profile.name.substring(0, 1).toUpperCase() : '?',
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Name & Role
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profile.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50], // Consider using Theme colors for dark mode later
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          profile.role.toUpperCase(),
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats Row
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Followers', profile.followers.length.toString()),
                      _buildStatColumn('Following', profile.favoriteOrgs.length.toString()),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const Divider(thickness: 1),
                
                // Bio
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(profile.bio!),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 1),
                ],
                
                // Favorites/Activity
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                         // Playlist/Favorites
                         ListTile(
                           leading: const Icon(Icons.favorite, color: Colors.pink),
                           title: const Text('Favorite Organizations'),
                           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                           onTap: () {
                             Navigator.of(context).push(
                               MaterialPageRoute(
                                 builder: (context) => FavoriteOrgsScreen(
                                   orgIds: profile.favoriteOrgs,
                                 ),
                               ),
                             );
                           },
                         ),
                         ListTile(
                           leading: const Icon(Icons.history, color: Colors.green),
                           title: const Text('Recent Activity'),
                           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                           onTap: () {
                             Navigator.of(context).push(
                               MaterialPageRoute(
                                 builder: (context) => const ActivityScreen(),
                               ),
                             );
                           },
                         ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
