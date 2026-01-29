import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../organizations/presentation/providers/organization_providers.dart';
import '../../../organizations/presentation/screens/org_profile_screen.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../../core/widgets/animated_widgets.dart'; // Import AnimatedWidgets

class SuggestedOrgsWidget extends ConsumerWidget {
  const SuggestedOrgsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For "Suggested", we'll just use "All Orgs" for now, or you could filter logic
    final allOrgsAsync = ref.watch(allOrganizationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Suggested for you',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        allOrgsAsync.when(
          data: (orgs) {
            if (orgs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No organizations found.'),
              );
            }
            return StaggeredList(
              itemCount: orgs.length, // StaggeredList creates ListView internally
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final org = orgs[index];
                
                // Check if current user follows this org
                final authState = ref.watch(firebaseAuthNotifierProvider);
                bool isFollowing = false;
                if (authState is Authenticated) {
                   isFollowing = authState.user.favoriteOrgs.contains(org.id);
                }

                return ScaleFadeIn(
                  delay: Duration(milliseconds: 50 * index),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Hero(
                          tag: 'org_${org.id}', // Add Hero for potential navigation
                          child: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(org.name.substring(0, 1).toUpperCase()),
                          ),
                        ),
                        title: Text(org.name),
                        subtitle: Text(org.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: authState is! Authenticated 
                          ? null 
                          : AnimatedScaleButton(
                              onTap: () async {
                                 final repo = ref.read(profileRepositoryProvider);
                                 try {
                                   if (isFollowing) {
                                     await repo.removeFavoriteOrganization(authState.user.id, org.id);
                                   } else {
                                     await repo.addFavoriteOrganization(authState.user.id, org.id);
                                   }
                                   ref.read(firebaseAuthNotifierProvider.notifier).refreshUser();
                                   ref.invalidate(allOrganizationsProvider);
                                 } catch (e) {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                 }
                              },
                              child: OutlinedButton(
                                onPressed: null, // Handled by AnimatedScaleButton onTap
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isFollowing ? Colors.blue : null,
                                  foregroundColor: isFollowing ? Colors.white : Colors.blue,
                                ),
                                child: Text(isFollowing ? 'Following' : 'Follow'),
                              ),
                            ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OrgProfileScreen(organization: org),
                            ),
                          );
                        },
                      ),
                      if (index < orgs.length - 1) const Divider(height: 1),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading suggestions: $err'),
          ),
        ),
      ],
    );
  }
}
