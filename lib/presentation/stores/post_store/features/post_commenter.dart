// Comentários

import 'dart:async';
import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_dependencies.dart';
import 'package:social_feed_app/presentation/stores/post_store/utils/post_store_helpers.dart';

class PostCommenter {
  final PostStoreState state;
  final PostStoreDependencies dependencies;
  final PostStoreHelpers helpers;

  PostCommenter(this.state, this.dependencies, this.helpers);

  @action
  Future<void> addComment(String postId) async {
    _incrementCommentInList(state.posts, postId);
    _incrementCommentInList(state.optimisticPosts, postId);
    
    unawaited(_addCommentInBackground(postId));
  }

  void _incrementCommentInList(ObservableList<Post> list, String postId) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1) {
      list[index] = list[index].copyWith(comments: list[index].comments + 1);
    }
  }

  Future<void> _addCommentInBackground(String postId) async {
    try {
      if (state.currentUserId != null) {
        const comment = 'Novo comentário';
        await dependencies.repository.addComment(postId, state.currentUserId!, comment);
      }
    } catch (e) {
      _decrementCommentInList(state.posts, postId);
      _decrementCommentInList(state.optimisticPosts, postId);
    }
  }

  void _decrementCommentInList(ObservableList<Post> list, String postId) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1 && list[index].comments > 0) {
      list[index] = list[index].copyWith(comments: list[index].comments - 1);
    }
  }
}