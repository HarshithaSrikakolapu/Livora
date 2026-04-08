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
      fullName: (data['fullName'] ?? data['name'] ?? '') as String,
      role: data['role'] as String? ?? 'user',
      phone: data['phone'] as String?,
      avatarUrl: (data['avatarUrl'] ?? data['profile_photo']) as String?,
      bio: data['bio'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      stats: Map<String, int>.from(data['stats'] ?? {}),
      isApproved: data['isApproved'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      favoriteOrgs: List<String>.from(data['favorite_orgs'] ?? []),
    );
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['profile_image'] as String?,
      bio: json['bio'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      stats: json['stats'] != null ? Map<String, int>.from(json['stats']) : const {'postsCount': 0, 'followersCount': 0, 'followingCount': 0},
      isApproved: json['isApproved'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      favoriteOrgs: json['favorite_orgs'] != null ? List<String>.from(json['favorite_orgs']) : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'createdAt': createdAt.toIso8601String(),
      'favorite_orgs': favoriteOrgs,
    };
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
