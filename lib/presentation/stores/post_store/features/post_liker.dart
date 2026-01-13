// Curtidas

import 'dart:async';
import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_dependencies.dart';
import 'package:social_feed_app/presentation/stores/post_store/utils/post_store_helpers.dart';

class PostLiker {
  final PostStoreState state;
  final PostStoreDependencies dependencies;
  final PostStoreHelpers helpers;
  
  final Map<String, Completer<void>> _likeCompleters = {};

  PostLiker(this.state, this.dependencies, this.helpers);

  @action
  Future<void> likePost(String postId) async {
    if (state.currentUserId == null) return;

    if (_likeCompleters.containsKey(postId)) {
      return;
    }

    final post = helpers.findPostById(postId);
    if (post == null) return;

    final alreadyLiked = post.likedBy.contains(state.currentUserId!);
    final newState = !alreadyLiked;
    
    _toggleLikeInList(state.posts, postId, state.currentUserId!, newState);
    _toggleLikeInList(state.optimisticPosts, postId, state.currentUserId!, newState);
    
    _toggleLikeInBackground(postId, state.currentUserId!, newState);
  }

  void _toggleLikeInList(
    ObservableList<Post> list, 
    String postId, 
    String userId,
    bool isLiking,
  ) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = list[index];
      
      if (isLiking) {
        if (!post.likedBy.contains(userId)) {
          list[index] = post.withLikeAdded(userId);
        }
      } else {
        if (post.likedBy.contains(userId)) {
          list[index] = post.withLikeRemoved(userId);
        }
      }
    }
  }

  Future<void> _toggleLikeInBackground(
    String postId, 
    String userId, 
    bool isLiking,
  ) async {
    final completer = Completer<void>();
    _likeCompleters[postId] = completer;
    
    try {
      await dependencies.repository.toggleLike(postId, userId);
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      
      Future.delayed(const Duration(seconds: 2), () {
        final currentPost = helpers.findPostById(postId);
        if (currentPost != null) {
          final currentState = currentPost.likedBy.contains(userId);
          if (currentState == isLiking) {
            _toggleLikeInList(state.posts, postId, userId, !isLiking);
            _toggleLikeInList(state.optimisticPosts, postId, userId, !isLiking);
          }
        }
      });
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        _likeCompleters.remove(postId);
      });
    }
  }
}