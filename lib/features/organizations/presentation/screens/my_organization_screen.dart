import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/organization_providers.dart';
import 'org_profile_screen.dart';
import 'edit_org_profile_screen.dart';
import '../../domain/entities/organization.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/app_button.dart';

class MyOrganizationScreen extends ConsumerWidget {
  const MyOrganizationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myOrgAsync = ref.watch(currentOrganizationProvider);

    return myOrgAsync.when(
      data: (org) {
        if (org != null) {
          // Organization profile exists, show it
          return OrgProfileScreen(organization: org);
        } else {
          // Organization profile does NOT exist yet.
          // Show a screen to create it.
          // We can use EditOrgProfileScreen with a dummy Organization object, 
          // but we need to ensure the ID matches the user ID.
          
          final authState = ref.watch(firebaseAuthNotifierProvider);
          if (authState is! Authenticated) {
            return const Scaffold(body: Center(child: Text('Not authenticated')));
          }
          
          // Create dummy org for creation
          final newOrg = Organization(
            id: authState.user.id,
            name: authState.user.fullName, // Default to user name
            email: authState.user.email,
            phone: authState.user.phone ?? '',
            address: '',
            contactPerson: authState.user.fullName,
            isLive: false,
          );
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Setup Organization'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: FadeInUp(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.business, size: 80, color: Theme.of(context).iconTheme.color?.withOpacity(0.5) ?? Colors.grey),
                     const SizedBox(height: 16),
                     Text(
                       'Welcome!',
                       style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                         fontWeight: FontWeight.bold,
                         color: Theme.of(context).colorScheme.onBackground,
                       ),
                     ),
                     const SizedBox(height: 8),
                     Text(
                       'Please set up your organization profile\nto start appearing in the directory.',
                       textAlign: TextAlign.center,
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                         color: ColorPalette.textSecondary.withOpacity(0.7),
                       ),
                     ),
                     const SizedBox(height: 32),
                     AppButton(
                       text: 'Create Profile',
                       icon: Icons.add,
                       type: AppButtonType.primary,
                       onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditOrgProfileScreen(organization: newOrg),
                            ),
                          ).then((_) {
                            // Refresh provider after return
                            ref.invalidate(currentOrganizationProvider);
                          });
                       }, 
                     ),
                      const SizedBox(height: 20),
                     TextButton(
                       onPressed: () async {
                         await ref.read(firebaseAuthNotifierProvider.notifier).logout();
                         if (context.mounted) context.go('/login');
                       },
                       child: Text(
                         'Logout',
                         style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                       ),
                     ),
                  ],
                ),
              ),
            ),
          );
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
