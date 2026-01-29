import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

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

  Future<void> addFavoriteOrg(String userId, String orgId) async {
    await firestore.collection('users').doc(userId).update({
      'favorite_orgs': FieldValue.arrayUnion([orgId])
    });
  }

  Future<void> removeFavoriteOrg(String userId, String orgId) async {
    await firestore.collection('users').doc(userId).update({
      'favorite_orgs': FieldValue.arrayRemove([orgId])
    });
  }
  
  UserProfile _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      profilePhoto: data['profile_photo'],
      bio: data['bio'],
      followers: List<String>.from(data['followers'] ?? []),
      favoriteOrgs: List<String>.from(data['favorite_orgs'] ?? []),
    );
  }

  Map<String, dynamic> _toFirestore(UserProfile profile) {
    return {
      'name': profile.name,
      'email': profile.email,
      'role': profile.role,
      'profile_photo': profile.profilePhoto,
      'bio': profile.bio,
      'followers': profile.followers,
      'favorite_orgs': profile.favoriteOrgs,
    };
  }
}
