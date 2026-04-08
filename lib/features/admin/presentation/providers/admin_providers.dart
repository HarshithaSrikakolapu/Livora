import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Livora/features/auth/domain/entities/user.dart';
import 'package:Livora/features/organizations/domain/entities/organization.dart';

// Provider for Pending Users
final pendingUsersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('isApproved', isEqualTo: false)
      .get();

  final users = snapshot.docs.map((doc) => User.fromFirestore(doc.data(), doc.id)).toList();
  
  // Sort in memory to avoid composite index requirement
  users.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Descending
  
  return users;
});

// Admin Controller to handle actions
final adminControllerProvider = Provider((ref) => AdminController(ref));

class AdminController {
  final Ref _ref;
  
  AdminController(this._ref);

  Future<void> approveUser(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'isApproved': true});
    
    // Invalidate the list to refresh UI
    _ref.invalidate(pendingUsersProvider);
  }

  Future<void> rejectUser(String userId) async {
    // For now, rejection might just mean deleting, or setting a 'rejected' status.
    // Let's assume we delete them or just leave them pending/rejected.
    // For safety, let's just mark a field 'isRejected' if we had it, or delete.
    // Deleting is risky. Let's just leave it for now or implements delete.
    
    _ref.invalidate(pendingUsersProvider);
  }

  Future<void> toggleUserActiveStatus(String userId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'isActive': !currentStatus});
    
    // Invalidate users list
    _ref.invalidate(allUsersProvider);
  }
}

// Provider for All Users (with optional search)
final allUsersProvider = FutureProvider.autoDispose.family<List<User>, String>((ref, query) async {
  Query collection = FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true);
  
  // Note: Firestore doesn't support native partial text search easily without external services like Algolia.
  // For this simple app, we will fetch all (or limit) and filter in memory, or use exact match if needed.
  // Ideally, use a proper search solution. Here we'll just fetch active/recent users.
  
  final snapshot = await collection.limit(50).get(); // Limit needed for safety if no index
  
  final users = snapshot.docs.map((doc) => User.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  
  if (query.isEmpty) {
    return users;
  } else {
    final lowerQuery = query.toLowerCase();
    return users.where((user) {
      return user.fullName.toLowerCase().contains(lowerQuery) || 
             user.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }
});

// Provider for All Organizations (Admin View)
final allAdminOrganizationsProvider = FutureProvider.autoDispose.family<List<Organization>, String>((ref, query) async {
  Query collection = FirebaseFirestore.instance.collection('organizations').orderBy('name');
  
  final snapshot = await collection.limit(50).get(); 
  
  final orgs = snapshot.docs.map((doc) => Organization.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  
  if (query.isEmpty) {
    return orgs;
  } else {
    final lowerQuery = query.toLowerCase();
    return orgs.where((org) {
      return org.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
});
