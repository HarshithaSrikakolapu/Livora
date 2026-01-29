
import '../entities/relationship.dart';
import '../repositories/social_repository.dart';

class SendConnectionRequest {
  final SocialRepository repository;

  SendConnectionRequest(this.repository);

  Future<void> call(String currentUserId, String userName, String? userAvatar, String targetUserId) {
    return repository.sendConnectionRequest(currentUserId, userName, userAvatar, targetUserId);
  }
}

class AcceptConnectionRequest {
  final SocialRepository repository;

  AcceptConnectionRequest(this.repository);

  Future<void> call(String currentUserId, String fromUserId) {
    return repository.acceptConnectionRequest(currentUserId, fromUserId);
  }
}

class GetPendingRequests {
  final SocialRepository repository;

  GetPendingRequests(this.repository);

  Stream<List<Relationship>> call(String userId) {
    return repository.getPendingRequests(userId);
  }
}

class GetConnectionStatus {
  final SocialRepository repository;

  GetConnectionStatus(this.repository);

  Future<Relationship?> call(String currentUserId, String targetUserId) {
    return repository.getConnectionStatus(currentUserId, targetUserId);
  }
}

class GetConnections {
  final SocialRepository repository;

  GetConnections(this.repository);

  Stream<List<Relationship>> call(String userId) {
    return repository.getConnections(userId);
  }
}
