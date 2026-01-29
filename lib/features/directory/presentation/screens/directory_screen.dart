import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/directory_providers.dart';
import '../widgets/org_list_tile.dart';
import '../widgets/search_bar_widget.dart';
import '../../../organizations/presentation/screens/org_profile_screen.dart';
import '../../../../core/widgets/animated_widgets.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredOrgsAsync = ref.watch(filteredOrganizationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory'),
      ),
      body: Column(
        children: [
          const FadeInUp(child: SearchBarWidget()),
          Expanded(
            child: filteredOrgsAsync.when(
              data: (orgs) {
                if (orgs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No organizations found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                return StaggeredList(
                  itemCount: orgs.length,
                  itemBuilder: (context, index) {
                    final org = orgs[index];
                    return OrgListTile(
                      organization: org,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OrgProfileScreen(organization: org),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
