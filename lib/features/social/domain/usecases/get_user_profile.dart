
import 'package:Livora/features/auth/domain/entities/user.dart';
import 'package:Livora/features/social/domain/repositories/social_repository.dart';

class GetUserProfile {
  final SocialRepository repository;

  GetUserProfile(this.repository);

  Future<User?> call(String userId) {
    return repository.getUserProfile(userId);
  }
}
