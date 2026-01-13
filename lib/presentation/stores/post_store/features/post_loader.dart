// Carregamento de posts

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_dependencies.dart';
import 'package:social_feed_app/presentation/stores/post_store/computed/post_store_computed.dart';
import 'package:social_feed_app/presentation/stores/post_store/utils/post_store_helpers.dart';

class PostLoader {
  final PostStoreState state;
  final PostStoreDependencies dependencies;
  final PostStoreHelpers helpers;
  final PostStoreComputed computed;
  
  DocumentSnapshot? _lastDocument;

  PostLoader(this.state, this.dependencies, this.helpers, this.computed);

  @action
  Future<void> loadPosts() async {
    state.isLoading = true;
    state.errorMessage = null;
    _lastDocument = null;

    helpers.cleanupStaleProcessing();

    try {
      final loadedPosts = await dependencies.repository.getPosts(
        limit: 10,
        currentUserId: state.currentUserId,
      );
      
      helpers.removeSyncedOptimisticPosts(loadedPosts);
      state.posts.clear();
      state.posts.addAll(loadedPosts);
      
      helpers.fixPostsOptimisticFlags();
      
      if (loadedPosts.isNotEmpty) {
        final lastDoc = await _getLastDocumentSnapshot();
        _lastDocument = lastDoc;
        state.hasMorePosts = loadedPosts.length == 10;
      } else {
        state.hasMorePosts = false;
      }
    } catch (e) {
      state.errorMessage = 'Erro ao carregar posts: $e';
    } finally {
      state.isLoading = false;
    }
  }

  @action
  Future<void> loadMorePosts() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMorePosts) return;
    
    state.isLoadingMore = true;
    state.errorMessage = null;

    try {
      final loadedPosts = await dependencies.repository.getPosts(
        limit: 10,
        lastDocument: _lastDocument,
        currentUserId: state.currentUserId,
      );
      
      if (loadedPosts.isNotEmpty) {
        state.posts.addAll(loadedPosts);
        
        helpers.fixPostsOptimisticFlags();
        
        if (loadedPosts.isNotEmpty) {
          final lastDoc = await _getLastDocumentSnapshot();
          _lastDocument = lastDoc;
        }
        
        state.hasMorePosts = loadedPosts.length == 10;
      } else {
        state.hasMorePosts = false;
      }
    } catch (e) {
      state.errorMessage = 'Erro ao carregar mais posts: $e';
    } finally {
      state.isLoadingMore = false;
    }
  }

  @action
  Future<void> refreshPosts() async {
    state.isLoading = true;
    _lastDocument = null;
    await loadPosts();
  }

  @action
  Future<List<Post>> loadLikedPosts() async {
    if (state.currentUserId == null) {
      state.errorMessage = 'Usuário não identificado';
      return [];
    }
    
    try {
      return await dependencies.repository.getPostsLikedByUser(state.currentUserId!);
    } catch (e) {
      state.errorMessage = 'Erro ao carregar posts curtidos: $e';
      return [];
    }
  }

  Future<DocumentSnapshot?> _getLastDocumentSnapshot() async {
    if (state.posts.isEmpty) return null;
    
    try {
      final lastPost = state.posts.last;
      return await dependencies.firebaseService.postsCollection.doc(lastPost.id).get();
    } catch (e) {
      return null;
    }
  }
}