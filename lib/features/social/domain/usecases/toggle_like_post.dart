
import 'package:Livora/features/social/domain/repositories/social_repository.dart';

class ToggleLikePost {
  final SocialRepository repository;

  ToggleLikePost(this.repository);

  Future<void> call(String postId, String userId) {
    return repository.likePost(postId, userId);
  }
}
