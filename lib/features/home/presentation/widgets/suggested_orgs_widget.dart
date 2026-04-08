
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/organizations/presentation/providers/organization_providers.dart';
import 'package:Livora/features/organizations/presentation/screens/org_profile_screen.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/features/profile/presentation/providers/profile_providers.dart';
import 'package:Livora/core/widgets/animated_widgets.dart';
import 'package:Livora/core/widgets/custom_card.dart'; // Use CustomCard

class SuggestedOrgsWidget extends ConsumerWidget {
  const SuggestedOrgsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrgsAsync = ref.watch(allOrganizationsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Text(
            'Suggested for you',
             style: theme.textTheme.titleMedium?.copyWith(
               fontWeight: FontWeight.bold,
               color: theme.colorScheme.onSurface.withOpacity(0.8),
             ),
          ),
        ),
        allOrgsAsync.when(
          data: (orgs) {
            if (orgs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('No suggestions available.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
              );
            }
            
            // Limit to 5 suggestions for home screen clarity
            final displayOrgs = orgs.take(5).toList();
            
            return ListView.separated(
              itemCount: displayOrgs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final org = displayOrgs[index];
                final authState = ref.watch(firebaseAuthNotifierProvider);
                bool isFollowing = false;
                if (authState is Authenticated) {
                   isFollowing = authState.user.favoriteOrgs.contains(org.id);
                }

                return ScaleFadeIn(
                  delay: Duration(milliseconds: 50 * index),
                  child: CustomCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OrgProfileScreen(organization: org),
                        ),
                      );
                    },
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Logo
                        Hero(
                          tag: 'suggested_org_${org.id}',
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.primaryColor.withOpacity(0.1),
                              image: org.logoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(org.logoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: org.logoUrl == null
                                ? Center(
                                    child: Text(
                                      org.name.substring(0, 1).toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18, 
                                        color: theme.primaryColor
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                org.name,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                org.category,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Follow Button
                        if (authState is Authenticated)
                          SizedBox(
                            height: 32,
                            child: AnimatedScaleButton(
                              onTap: () async {
                                 // ... Same logic
                              },
                              child: OutlinedButton(
                                onPressed: () async {
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
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  backgroundColor: isFollowing ? theme.primaryColor : Colors.transparent,
                                  side: BorderSide(color: isFollowing ? Colors.transparent : theme.dividerColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(
                                  isFollowing ? 'Following' : 'Follow',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isFollowing ? Colors.white : theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor)),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading suggestions', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ),
      ],
    );
  }
}
