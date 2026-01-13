// Atualização

import 'dart:async';
import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_dependencies.dart';
import 'package:social_feed_app/presentation/stores/post_store/utils/post_store_helpers.dart';

class PostUpdater {
  final PostStoreState state;
  final PostStoreDependencies dependencies;
  final PostStoreHelpers helpers;

  PostUpdater(this.state, this.dependencies, this.helpers);

  @action
  Future<void> updatePost(String postId, String newContent) async {
    _updatePostInList(state.posts, postId, newContent);
    _updatePostInList(state.optimisticPosts, postId, newContent);
    
    unawaited(_updatePostInBackground(postId, newContent));
  }

  void _updatePostInList(ObservableList<Post> list, String postId, String newContent) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1) {
      list[index] = list[index].copyWith(
        content: newContent,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> _updatePostInBackground(String postId, String newContent) async {
    try {
      final post = helpers.findPostById(postId);
      if (post != null) {
        await dependencies.repository.updatePost(post.copyWith(content: newContent));
      }
    } catch (e) {
      // Erro silencioso - apenas log
    }
  }
}