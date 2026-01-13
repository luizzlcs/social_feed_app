// Criação de posts

import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_dependencies.dart';
import 'package:social_feed_app/presentation/stores/post_store/utils/post_store_helpers.dart';
import 'package:social_feed_app/presentation/stores/post_store/sync/optimistic_post_manager.dart';

class PostCreator {
  final PostStoreState state;
  final PostStoreDependencies dependencies;
  final PostStoreHelpers helpers;
  final OptimisticPostManager optimisticManager;

  PostCreator(this.state, this.dependencies, this.helpers, this.optimisticManager);

  @action
  Future<void> createPost(String content, {String? imagePath}) async {
    try {
      final optimisticPost = _createOptimisticPost(content, imagePath);
      optimisticManager.addOptimisticPost(optimisticPost);
      _savePostInBackground(optimisticPost, imagePath);
    } catch (e) {
      state.errorMessage = 'Erro ao criar post: $e';
    }
  }

  Post _createOptimisticPost(String content, String? imagePath) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    return Post(
      id: 'temp_${timestamp}_${state.currentUserId ?? 'unknown'}',
      userId: state.currentUserId ?? 'unknown_user',
      username: 'Você',
      content: content,
      imageUrl: imagePath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likes: 0,
      comments: 0,
      likedBy: [],
      isOptimistic: true,
    );
  }

  Future<void> _savePostInBackground(Post optimisticPost, String? imagePath) async {
    try {
      final realPost = optimisticPost.copyWith(isOptimistic: false);
      final savedPost = await dependencies.repository.createPost(realPost, imagePath: imagePath);
      optimisticManager.updateOptimisticPostWithRealData(optimisticPost.id, savedPost);
    } catch (e) {
      optimisticManager.markOptimisticPostAsFailed(optimisticPost.id, e.toString());
    }
  }
}