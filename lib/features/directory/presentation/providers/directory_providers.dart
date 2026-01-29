import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/organizations/presentation/providers/organization_providers.dart';
import '../../../../features/organizations/domain/entities/organization.dart';

// State provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for filtered organizations
final filteredOrganizationsProvider = FutureProvider<List<Organization>>((ref) async {
  final allOrgsAsync = await ref.watch(allOrganizationsProvider.future);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return allOrgsAsync;
  }

  return allOrgsAsync.where((org) {
    return org.name.toLowerCase().contains(query) ||
           org.address.toLowerCase().contains(query);
  }).toList();
});
