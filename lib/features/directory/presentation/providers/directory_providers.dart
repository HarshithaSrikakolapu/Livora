import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/organizations/presentation/providers/organization_providers.dart';
import 'package:Livora/features/organizations/domain/entities/organization.dart';

// State provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// State provider for the selected category
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Provider for filtered organizations
final filteredOrganizationsProvider = FutureProvider<List<Organization>>((ref) async {
  final allOrgsAsync = await ref.watch(allOrganizationsProvider.future);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);

  List<Organization> filtered = allOrgsAsync;

  // Filter by search query
  if (query.isNotEmpty) {
    filtered = filtered.where((org) {
      return org.name.toLowerCase().contains(query) ||
             org.address.toLowerCase().contains(query);
    }).toList();
  }

  // Filter by category
  if (selectedCategory != 'All') {
    filtered = filtered.where((org) => org.category == selectedCategory).toList();
  }

  return filtered;
});
