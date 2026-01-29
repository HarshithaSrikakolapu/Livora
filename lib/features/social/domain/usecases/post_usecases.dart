
import 'dart:io';

import '../entities/post.dart';
import '../repositories/social_repository.dart';

class CreatePost {
  final SocialRepository repository;

  CreatePost(this.repository);

  Future<void> call(Post post) {
    return repository.createPost(post);
  }
}

class GetGlobalFeed {
  final SocialRepository repository;

  GetGlobalFeed(this.repository);

  Stream<List<Post>> call({int limit = 20}) {
    return repository.getGlobalFeed(limit: limit);
  }
}

class GetUserPosts {
  final SocialRepository repository;

  GetUserPosts(this.repository);

  Stream<List<Post>> call(String userId) {
    return repository.getUserPosts(userId);
  }
}

class UploadPostImage {
  final SocialRepository repository;

  UploadPostImage(this.repository);

  Future<String> call(File file, String path) {
    return repository.uploadPostImage(file, path);
  }
}
