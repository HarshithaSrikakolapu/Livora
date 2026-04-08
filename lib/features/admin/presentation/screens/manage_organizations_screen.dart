import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/organizations/domain/entities/organization.dart';
import 'package:Livora/features/admin/presentation/providers/admin_providers.dart';
import 'package:Livora/features/organizations/presentation/screens/org_profile_screen.dart';

class ManageOrganizationsScreen extends ConsumerStatefulWidget {
  const ManageOrganizationsScreen({super.key});

  @override
  ConsumerState<ManageOrganizationsScreen> createState() => _ManageOrganizationsScreenState();
}

class _ManageOrganizationsScreenState extends ConsumerState<ManageOrganizationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgsAsync = ref.watch(allAdminOrganizationsProvider(_searchQuery));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manage Organizations'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search organizations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Orgs List
          Expanded(
            child: orgsAsync.when(
              data: (orgs) {
                if (orgs.isEmpty) {
                  return const Center(child: Text('No organizations found.'));
                }
                return ListView.builder(
                  itemCount: orgs.length,
                  itemBuilder: (context, index) {
                    final org = orgs[index];
                    return _buildOrgTile(context, org);
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

  Widget _buildOrgTile(BuildContext context, Organization org) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            org.name.isNotEmpty ? org.name[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.blue[900]),
          ),
        ),
        title: Text(org.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(org.address, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to Org Profile for view/edit
           Navigator.of(context).push(
             MaterialPageRoute(
               builder: (context) => OrgProfileScreen(organization: org),
             ),
           );
        },
      ),
    );
  }
}
