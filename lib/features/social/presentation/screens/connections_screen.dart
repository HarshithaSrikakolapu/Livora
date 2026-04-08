
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/social/presentation/providers/social_providers.dart';
import 'package:Livora/features/social/presentation/widgets/user_avatar.dart';
import 'user_profile_screen.dart';
import 'package:Livora/features/social/domain/entities/relationship.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Network'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Connections'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ConnectionsList(),
          _RequestsList(),
        ],
      ),
    );
  }
}

class _RequestsList extends ConsumerWidget {
  const _RequestsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingRequestsStreamProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('No pending requests'));
        }
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return ListTile(
              leading: UserAvatar(
                userName: request.memberName ?? 'User',
                avatarUrl: request.memberAvatar,
              ),
              title: Text(request.memberName ?? 'Unknown User'),
              subtitle: const Text('Sent you a request'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                       ref.read(acceptConnectionRequestProvider).call(request.followingId, request.followerId); 
                       // Note: followingId should be ME, followerId is THEM.
                       // Implementation of usecase might need check.
                       // My 'relationship' mapping in dataSource: 
                       // followerId = doc.id (THEM), followingId = userId (ME).
                       // acceptConnectionRequest(currentUser, fromUser).
                       // So: accept(ME, THEM). Correct.
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      // Reject not implemented properly yet
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserProfileScreen(userId: request.followerId)),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _ConnectionsList extends ConsumerWidget {
  const _ConnectionsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionsAsync = ref.watch(connectionsStreamProvider);

    return connectionsAsync.when(
      data: (connections) {
        if (connections.isEmpty) {
          return const Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.people_outline, size: 64, color: Colors.grey),
                 SizedBox(height: 16),
                 Text('Your connections will appear here', style: TextStyle(color: Colors.grey)),
               ],
             ),
          );
        }
        return ListView.builder(
          itemCount: connections.length,
          itemBuilder: (context, index) {
            final friend = connections[index];
            return ListTile(
              leading: UserAvatar(
                userName: friend.memberName ?? 'User',
                avatarUrl: friend.memberAvatar,
              ),
              title: Text(friend.memberName ?? 'Unknown User'),
              subtitle: const Text('Connected'),
              trailing: IconButton(
                 icon: const Icon(Icons.more_vert),
                 onPressed: () {
                    // Start chat or unfriend options
                 },
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserProfileScreen(userId: friend.followerId)),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
