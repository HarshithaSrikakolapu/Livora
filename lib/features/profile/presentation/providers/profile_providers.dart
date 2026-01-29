import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../organizations/presentation/providers/organization_providers.dart';

// Data Source
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(FirebaseFirestore.instance);
});

// Repository

// Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(profileRemoteDataSourceProvider),
    ref.watch(organizationRemoteDataSourceProvider),
  );
});

// Current User Profile Provider
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(firebaseAuthNotifierProvider);
  
  if (authState is Authenticated) {
    final uid = authState.user.id;
    final repository = ref.watch(profileRepositoryProvider);
    return repository.getUserProfile(uid);
  }
  
  return null;
});

// Provider to watch any user profile by ID
final userProfileFamilyProvider = FutureProvider.family<UserProfile?, String>((ref, uid) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile(uid);
});
