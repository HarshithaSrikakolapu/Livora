
import 'package:Livora/features/auth/domain/entities/user.dart';
import 'package:Livora/features/social/domain/repositories/social_repository.dart';

class UpdateUserProfile {
  final SocialRepository repository;

  UpdateUserProfile(this.repository);

  Future<void> call(User user) {
    return repository.updateUserProfile(user);
  }
}
