// Funções auxiliares

import 'package:flutter/foundation.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_dependencies.dart';

class PostStoreHelpers {
  final PostStoreState state;
  final PostStoreDependencies dependencies;

  PostStoreHelpers(this.state, this.dependencies);

  /// Encontra um post pelo ID em qualquer lista
  Post? findPostById(String postId) {
    try {
      return state.posts.firstWhere((post) => post.id == postId);
    } catch (_) {
      try {
        return state.optimisticPosts.firstWhere((post) => post.id == postId);
      } catch (_) {
        return null;
      }
    }
  }

  /// Verifica se um post existe
  bool postExists(String postId) {
    return state.posts.any((post) => post.id == postId) ||
           state.optimisticPosts.any((post) => post.id == postId);
  }

  /// Limpa processamentos antigos
  void cleanupStaleProcessing() {
    final cutoffTime = DateTime.now().subtract(const Duration(seconds: 30));
    
    final staleIds = state.processingPostIds.where((id) {
      final startTime = state.processingStartTimes[id];
      return startTime != null && startTime.isBefore(cutoffTime);
    }).toList();
    
    for (final id in staleIds) {
      state.processingPostIds.remove(id);
      state.processingStartTimes.remove(id);
    }
  }

  /// Remove posts otimistas que já foram sincronizados
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

  /// Corrige flags isOptimistic
  void fixPostsOptimisticFlags() {
    if (kDebugMode) {
      print('🔧 [PostStoreHelpers] Corrigindo flags isOptimistic...');
    }
    
    int correctedCount = 0;
    
    for (var i = 0; i < state.posts.length; i++) {
      final post = state.posts[i];
      
      if (post.isOptimistic && !state.processingPostIds.contains(post.id)) {
        state.posts[i] = post.copyWith(isOptimistic: false);
        correctedCount++;
      }
    }
    
    if (kDebugMode && correctedCount > 0) {
      print('🎯 Total de posts corrigidos: $correctedCount');
    }
  }
}