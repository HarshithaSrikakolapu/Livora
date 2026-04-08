import 'package:Livora/features/social/domain/repositories/social_repository.dart';

class RemoveConnection {
  final SocialRepository repository;

  RemoveConnection(this.repository);

  Future<void> call(String currentUserId, String targetUserId) {
    return repository.removeConnection(currentUserId, targetUserId);
  }
}