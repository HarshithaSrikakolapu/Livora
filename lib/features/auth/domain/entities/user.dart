import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? coverImageUrl;
  final Map<String, int> stats;
  final bool isApproved;
  final bool isActive;
  final DateTime createdAt;
  final List<String> favoriteOrgs;
  
  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.coverImageUrl,
    this.stats = const {'postsCount': 0, 'followersCount': 0, 'followingCount': 0},
    required this.isApproved,
    required this.isActive,
    required this.createdAt,
    this.favoriteOrgs = const [],
  });
  
  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] as String,
      fullName: data['fullName'] as String,
      role: data['role'] as String? ?? 'user',
      phone: data['phone'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      bio: data['bio'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      stats: Map<String, int>.from(data['stats'] ?? {}),
      isApproved: data['isApproved'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      favoriteOrgs: List<String>.from(data['favorite_orgs'] ?? []),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'coverImageUrl': coverImageUrl,
      'stats': stats,
      'isApproved': isApproved,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
      'favorite_orgs': favoriteOrgs,
    };
  }
  
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? coverImageUrl,
    Map<String, int>? stats,
    bool? isApproved,
    bool? isActive,
    DateTime? createdAt,
    List<String>? favoriteOrgs,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      stats: stats ?? this.stats,
      isApproved: isApproved ?? this.isApproved,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      favoriteOrgs: favoriteOrgs ?? this.favoriteOrgs,
    );
  }
}
