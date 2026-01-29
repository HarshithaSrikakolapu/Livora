
import '../../../auth/domain/entities/user.dart';
import '../repositories/social_repository.dart';

class UpdateUserProfile {
  final SocialRepository repository;

  UpdateUserProfile(this.repository);

  Future<void> call(User user) {
    return repository.updateUserProfile(user);
  }
}
