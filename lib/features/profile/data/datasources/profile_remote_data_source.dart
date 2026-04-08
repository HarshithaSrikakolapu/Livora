import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Livora/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> addFavoriteOrg(String userId, String orgId);
  Future<void> removeFavoriteOrg(String userId, String orgId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSourceImpl(this.firestore);

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return _fromFirestore(doc);
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await firestore.collection('users').doc(profile.id).set(_toFirestore(profile), SetOptions(merge: true));
  }

  @override
  Future<void> addFavoriteOrg(String userId, String orgId) async {
    await firestore.collection('users').doc(userId).update({
      'favorite_orgs': FieldValue.arrayUnion([orgId])
    });
  }

  @override
  Future<void> removeFavoriteOrg(String userId, String orgId) async {
    await firestore.collection('users').doc(userId).update({
      'favorite_orgs': FieldValue.arrayRemove([orgId])
    });
  }
  
  UserProfile _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['fullName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      profilePhoto: data['avatarUrl'] ?? data['profile_photo'],
      bio: data['bio'],
      phone: data['phone'],
      followers: List<String>.from(data['followers'] ?? []),
      favoriteOrgs: List<String>.from(data['favorite_orgs'] ?? []),
    );
  }

  Map<String, dynamic> _toFirestore(UserProfile profile) {
    return {
      'fullName': profile.name,
      'email': profile.email,
      'role': profile.role,
      'avatarUrl': profile.profilePhoto,
      'bio': profile.bio,
      'phone': profile.phone,
      'followers': profile.followers,
      'favorite_orgs': profile.favoriteOrgs,
    };
  }
}
