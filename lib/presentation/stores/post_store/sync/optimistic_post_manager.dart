// Gerenciador de posts otimistas

import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_dependencies.dart';
import 'package:social_feed_app/presentation/stores/post_store/utils/post_store_helpers.dart';
import 'package:social_feed_app/presentation/stores/post_store/sync/sync_error_handler.dart';

class OptimisticPostManager {
  final PostStoreState state;
  final PostStoreDependencies dependencies;
  final PostStoreHelpers helpers;
  final SyncErrorHandler errorHandler;

  OptimisticPostManager(
    this.state,
    this.dependencies,
    this.helpers,
    this.errorHandler,
  );

  @action
  void addOptimisticPost(Post optimisticPost) {
    state.optimisticPosts.insert(0, optimisticPost);
    addToProcessing(optimisticPost.id);
  }

  @action
  void addToProcessing(String postId) {
    state.processingPostIds.add(postId);
    state.processingStartTimes[postId] = DateTime.now();
  }

  @action
  void removeFromProcessing(String postId) {
    state.processingPostIds.remove(postId);
    state.processingStartTimes.remove(postId);
  }

  @action
  void updateOptimisticPostWithRealData(String postId, Post realPost) {
    final index = state.optimisticPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final synchronizedPost = realPost.copyWith(
        isOptimistic: false,
        syncFailed: false,
        syncError: null,
      );
      
      state.optimisticPosts[index] = synchronizedPost;
      
      removeFromProcessing(postId);
      
      if (!state.posts.any((post) => post.id == synchronizedPost.id)) {
        state.posts.insert(0, synchronizedPost);
      }
    }
  }

  @action
  void markOptimisticPostAsFailed(String postId, String error) {
    final index = state.optimisticPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      state.optimisticPosts[index] = state.optimisticPosts[index].copyWith(
        syncFailed: true,
        syncError: error,
      );
      
      removeFromProcessing(postId);
    }
  }

  @action
  void removeSyncedOptimisticPosts(List<Post> realPosts) {
    final realPostIds = realPosts.map((post) => post.id).toSet();
    
    state.processingPostIds.removeWhere((id) => realPostIds.contains(id));
    
    realPostIds.forEach((id) {
      state.processingStartTimes.remove(id);
    });
    
    state.optimisticPosts.removeWhere((post) => realPostIds.contains(post.id));
    
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5));
    state.optimisticPosts.removeWhere((post) => 
      post.isOptimistic && post.createdAt.isBefore(cutoffTime)
    );
  }

  @action
  void fixPostsOptimisticFlags() {
    if (kDebugMode) {
      print('🔧 [OptimisticPostManager] Corrigindo flags isOptimistic...');
    }
    
    int correctedCount = 0;
    
    for (var i = 0; i < state.posts.length; i++) {
      final post = state.posts[i];
      
      if (post.isOptimistic && !state.processingPostIds.contains(post.id)) {
        state.posts[i] = post.copyWith(isOptimistic: false);
        correctedCount++;
        
        if (kDebugMode) {
          print('✅ Corrigido post: ${post.id} (isOptimistic: true → false)');
        }
      }
    }
    
    if (kDebugMode && correctedCount > 0) {
      print('🎯 Total de posts corrigidos: $correctedCount');
    }
  }

  @action
  void cleanupOldOptimisticPosts() {
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5));
    final oldPosts = state.optimisticPosts
        .where((post) => post.isOptimistic && post.createdAt.isBefore(cutoffTime))
        .toList();
    
    for (final post in oldPosts) {
      state.optimisticPosts.remove(post);
      state.processingPostIds.remove(post.id);
      state.processingStartTimes.remove(post.id);
      
      if (kDebugMode) {
        print('🗑️ Removido post otimista antigo: ${post.id}');
      }
    }
  }

  @action
  void fixAllPostsOptimisticFlags() {
    if (kDebugMode) {
      print('🛠️ [OptimisticPostManager] Correção manual de flags isOptimistic iniciada');
    }
    
    fixPostsOptimisticFlags();
    cleanupOldOptimisticPosts();
    
    if (kDebugMode) {
      print('✅ [OptimisticPostManager] Correção manual completa');
    }
  }

  @action
  void emergencyResetAllOptimisticFlags() {
    if (kDebugMode) {
      print('🚨 [OptimisticPostManager] EMERGÊNCIA: Resetando todas as flags isOptimistic!');
    }
    
    int resetCount = 0;
    
    for (var i = 0; i < state.posts.length; i++) {
      if (state.posts[i].isOptimistic) {
        state.posts[i] = state.posts[i].copyWith(isOptimistic: false);
        resetCount++;
      }
    }
    
    for (var i = 0; i < state.optimisticPosts.length; i++) {
      final post = state.optimisticPosts[i];
      if (post.isOptimistic && !state.processingPostIds.contains(post.id)) {
        state.optimisticPosts[i] = post.copyWith(isOptimistic: false);
        resetCount++;
      }
    }
    
    cleanupOldOptimisticPosts();
    
    if (kDebugMode) {
      print('✅ [OptimisticPostManager] Reset completo!');
      print('   - Posts resetados: $resetCount');
      print('   - Posts otimistas: ${state.optimisticPosts.length}');
      print('   - Posts sendo processados: ${state.processingPostIds.length}');
    }
  }
}