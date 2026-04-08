import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/core/widgets/custom_card.dart';
import 'package:Livora/features/organizations/domain/entities/organization.dart';
import 'package:Livora/features/organizations/presentation/providers/organization_providers.dart';
import 'package:Livora/features/organizations/presentation/screens/org_profile_screen.dart';

class FavoriteOrgsScreen extends ConsumerWidget {
  final List<String> orgIds;

  const FavoriteOrgsScreen({super.key, required this.orgIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Favorite Organizations'),
      ),
      body: orgIds.isEmpty
          ? const Center(
              child: Text(
                'No favorite organizations yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orgIds.length,
              itemBuilder: (context, index) {
                final orgId = orgIds[index];
                final orgAsync = ref.watch(organizationByIdProvider(orgId));

                return orgAsync.when(
                  data: (org) {
                    if (org == null) return const SizedBox.shrink();
                    return _OrgListTile(org: org);
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text('Error loading $orgId'),
                );
              },
            ),
    );
  }
}

class _OrgListTile extends StatelessWidget {
  final Organization org;

  const _OrgListTile({required this.org});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrgProfileScreen(organization: org),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
          child: org.logoUrl == null
              ? Text(org.name.substring(0, 1).toUpperCase())
              : null,
        ),
        title: Text(
          org.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          org.category,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
