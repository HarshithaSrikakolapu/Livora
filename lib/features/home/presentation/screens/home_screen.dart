
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/features/directory/presentation/screens/directory_screen.dart';
import 'package:Livora/features/profile/presentation/screens/profile_screen.dart';
import 'package:Livora/features/organizations/presentation/screens/my_organization_screen.dart';
import 'package:Livora/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:Livora/features/home/presentation/widgets/live_wall_widget.dart';
import 'package:Livora/features/home/presentation/widgets/suggested_orgs_widget.dart';
import 'package:Livora/features/social/presentation/screens/social_feed_screen.dart';
import 'package:Livora/core/widgets/animated_widgets.dart';
import 'package:Livora/core/widgets/custom_nav_bar.dart';
import 'package:Livora/core/widgets/background_paths.dart';

import 'package:Livora/features/live/presentation/widgets/live_now_section.dart';
import 'package:Livora/features/live/presentation/widgets/upcoming_streams_section.dart';
import 'package:Livora/features/live/presentation/screens/go_live_screen.dart';
import 'package:Livora/features/live/presentation/providers/live_providers.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const SocialFeedScreen(),
    const DirectoryScreen(), 
    const ProfileTabPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firebaseAuthNotifierProvider);
    
    return BackgroundPaths(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true, // Crucial for floating navbar
        floatingActionButton: (_currentIndex == 0 && 
                               authState is Authenticated && 
                               authState.user.role == 'organization')
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GoLiveScreen()),
                  );
                },
                backgroundColor: const Color(0xFFE50914),
                icon: const Icon(Icons.live_tv_rounded, color: Colors.white),
                label: const Text('GO LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            : null,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutQuart,
          switchOutCurve: Curves.easeInQuad,
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _screens[_currentIndex],
          ),
        ),
        bottomNavigationBar: CustomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            CustomNavBarItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
            ),
            CustomNavBarItem(
              icon: Icons.rss_feed_rounded,
              selectedIcon: Icons.rss_feed_rounded,
              label: 'Social',
            ),
            CustomNavBarItem(
              icon: Icons.search_rounded,
              selectedIcon: Icons.search_rounded,
              label: 'Directory',
            ),
            CustomNavBarItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Wrapper to decide which profile screen to show
class ProfileTabPlaceholder extends ConsumerWidget {
  const ProfileTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseAuthNotifierProvider);
    
    if (authState is Authenticated && authState.user.role == 'organization') {
      return const MyOrganizationScreen();
    }
    return const ProfileScreen();
  }
}

// Moved original Home content to a Tab (except App Bar logic which matches Tab usually)
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseAuthNotifierProvider);
    final theme = Theme.of(context);
    String userName = 'User';
    
    if (authState is Authenticated) {
      userName = authState.user.fullName;
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Allow background to show if needed or handle cleaner
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 8),
            Text(
              'Livora',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Admin Button
           if (authState is Authenticated && authState.user.role == 'admin')
            IconButton(
              icon: Icon(Icons.admin_panel_settings_rounded, color: theme.colorScheme.primary),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                );
              },
            ),
           // Logout Button
           IconButton(
            icon: Icon(Icons.logout_rounded, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            onPressed: () async {
              await ref.read(firebaseAuthNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
       body: RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: () async {
          ref.invalidate(liveStreamsProvider);
          ref.invalidate(scheduledStreamsProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
           physics: const AlwaysScrollableScrollPhysics(),
           padding: const EdgeInsets.only(bottom: 100), // Space for fab/nav
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               FadeInUp(
                 child: Padding(
                   padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         'Hello,',
                         style: theme.textTheme.titleLarge?.copyWith(
                           color: theme.colorScheme.onSurface.withOpacity(0.6),
                         ),
                       ),
                       Text(
                         '$userName!',
                         style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary, // Make user name pop? Or Text Color?
                            // Let's keep it clean
                            // color: theme.colorScheme.onBackground, 
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
                FadeInUp(
                  delay: const Duration(milliseconds: 50),
                  child: const LiveNowSection(),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 75),
                  child: const UpcomingStreamsSection(),
                ),
               
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                 child: Divider(
                    height: 1, 
                    thickness: 1, 
                    color: theme.dividerColor.withOpacity(0.1)
                 ),
               ),

               const FadeInUp(
                 delay: Duration(milliseconds: 200),
                 child: SuggestedOrgsWidget(),
               ),
               
               const SizedBox(height: 80), 
             ],
           ),
        ),
      ),
    );
  }
}
