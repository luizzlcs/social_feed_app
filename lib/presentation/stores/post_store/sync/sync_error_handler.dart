// Tratamento de erros

import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/utils/post_store_helpers.dart';

class SyncErrorHandler {
  final PostStoreState state;
  final PostStoreHelpers helpers;

  SyncErrorHandler(this.state, this.helpers);

  @action
  void markPostAsFailed(String postId, String error) {
    _updatePostSyncStatus(state.posts, postId, error);
    _updatePostSyncStatus(state.optimisticPosts, postId, error);
    
    state.processingPostIds.remove(postId);
    state.processingStartTimes.remove(postId);
  }

  void _updatePostSyncStatus(ObservableList<Post> list, String postId, String error) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1) {
      list[index] = list[index].copyWith(
        syncFailed: true,
        syncError: error,
      );
    }
  }
}