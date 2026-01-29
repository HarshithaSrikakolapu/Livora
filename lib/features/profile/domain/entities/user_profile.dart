class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role; // 'user' | 'org' | 'admin'
  final String? profilePhoto;
  final String? bio;
  final List<String> followers;
  final List<String> favoriteOrgs; // IDs of favorite organizations

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhoto,
    this.bio,
    this.followers = const [],
    this.favoriteOrgs = const [],
  });
}
