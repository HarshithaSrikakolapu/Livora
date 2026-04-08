
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Livora/features/organizations/data/datasources/organization_remote_data_source.dart';
import 'package:Livora/features/organizations/data/repositories/organization_repository_impl.dart';
import 'package:Livora/features/organizations/domain/entities/organization.dart';
import 'package:Livora/features/organizations/domain/repositories/organization_repository.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';

// Data Source Provider
final organizationRemoteDataSourceProvider = Provider<OrganizationRemoteDataSource>((ref) {
  return OrganizationRemoteDataSourceImpl(FirebaseFirestore.instance);
});

// Repository Provider
final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepositoryImpl(ref.watch(organizationRemoteDataSourceProvider));
});

// Future Provider for Live Organizations
final liveOrganizationsProvider = FutureProvider<List<Organization>>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);
  final authState = ref.watch(firebaseAuthNotifierProvider);
  
  // Fetch all live organizations first
  final allLiveOrgs = await repository.getLiveOrganizations();
  
  // Filter based on user's following list
  if (authState is Authenticated) {
    final followingIds = authState.user.favoriteOrgs;
    return allLiveOrgs.where((org) => followingIds.contains(org.id)).toList();
  }
  
  // If not authenticated, show nothing (or could show all as discovery, but user asked for following)
  return []; 
});

// Future Provider for All Organizations (used for suggestions for now)
final allOrganizationsProvider = FutureProvider<List<Organization>>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return repository.getOrganizations();
});

// Future Provider for Current User's Organization (if they are an org admin)
final currentOrganizationProvider = FutureProvider.autoDispose<Organization?>((ref) async {
  final authState = ref.watch(firebaseAuthNotifierProvider);
  
  if (authState is Authenticated && authState.user.role == 'organization') {
    final repository = ref.watch(organizationRepositoryProvider);
    return repository.getOrganizationById(authState.user.id);
  }
  
  return null;
});

// Provider for specific organization by ID
final organizationByIdProvider = FutureProvider.family<Organization?, String>((ref, id) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return repository.getOrganizationById(id);
});
