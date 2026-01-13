// Exclusão

import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_dependencies.dart';
import 'package:social_feed_app/presentation/stores/post_store/utils/post_store_helpers.dart';
import 'package:social_feed_app/presentation/stores/post_store/sync/optimistic_post_manager.dart';

class PostDeleter {
  final PostStoreState state;
  final PostStoreDependencies dependencies;
  final PostStoreHelpers helpers;
  final OptimisticPostManager optimisticManager;

  PostDeleter(this.state, this.dependencies, this.helpers, this.optimisticManager);

  @action
  Future<void> deletePost(String postId) async {
    final postToRestore = helpers.findPostById(postId);
    
    state.posts.removeWhere((post) => post.id == postId);
    state.optimisticPosts.removeWhere((post) => post.id == postId);
    
    optimisticManager.addToProcessing(postId);
    _deletePostInBackground(postId, postToRestore);
  }

  Future<void> _deletePostInBackground(String postId, Post? postToRestore) async {
    try {
      await dependencies.repository.deletePost(postId);
    } catch (e) {
      if (postToRestore != null && !helpers.postExists(postId)) {
        if (postToRestore.isOptimistic) {
          state.optimisticPosts.add(postToRestore);
        } else {
          state.posts.add(postToRestore);
        }
      }
    } finally {
      optimisticManager.removeFromProcessing(postId);
    }
  }
}