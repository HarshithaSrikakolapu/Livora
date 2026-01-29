
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../../features/auth/presentation/providers/auth_state.dart';
import '../../../directory/presentation/screens/directory_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../organizations/presentation/screens/my_organization_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../widgets/live_wall_widget.dart';
import '../widgets/suggested_orgs_widget.dart';
import '../../../social/presentation/screens/social_feed_screen.dart';
import '../../../../core/widgets/animated_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const SocialFeedScreen(),
    const DirectoryScreen(), // Reusing directly or wrapping
    const ProfileTabPlaceholder(), // Logic to decide which profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'Social'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Directory'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Wrapper to decide which profile screen to show
class ProfileTabPlaceholder extends ConsumerWidget {
  const ProfileTabPlaceholder({Key? key}) : super(key: key);

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
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseAuthNotifierProvider);
    String userName = 'User';
    if (authState is Authenticated) {
      userName = authState.user.fullName;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 8),
            const Text('Livora'),
          ],
        ),
        actions: [
          // Admin Button
           if (authState is Authenticated && authState.user.role == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                );
              },
            ),
           // Logout Button
           IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(firebaseAuthNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
       body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh providers
        },
        child: SingleChildScrollView(
           physics: const AlwaysScrollableScrollPhysics(),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               FadeInUp(
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Text(
                     'Hello, $userName!',
                     style: Theme.of(context).textTheme.headlineSmall,
                   ),
                 ),
               ),
               const FadeInUp(
                 delay: Duration(milliseconds: 100),
                 child: LiveWallWidget(),
               ),
               const FadeInUp(
                 delay: Duration(milliseconds: 200),
                 child: Divider(height: 32, thickness: 1),
               ),
               const FadeInUp(
                 delay: Duration(milliseconds: 300),
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
