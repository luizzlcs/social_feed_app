//Classe base abstrata

import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_state.dart';
import 'package:social_feed_app/presentation/stores/post_store/core/post_store_dependencies.dart';
import 'package:social_feed_app/presentation/stores/post_store/computed/post_store_computed.dart';
import 'package:social_feed_app/presentation/stores/post_store/features/post_loader.dart';
import 'package:social_feed_app/presentation/stores/post_store/features/post_creator.dart';
import 'package:social_feed_app/presentation/stores/post_store/features/post_liker.dart';
import 'package:social_feed_app/presentation/stores/post_store/features/post_updater.dart';
import 'package:social_feed_app/presentation/stores/post_store/features/post_deleter.dart';
import 'package:social_feed_app/presentation/stores/post_store/features/post_commenter.dart';
import 'package:social_feed_app/presentation/stores/post_store/sync/optimistic_post_manager.dart';
import 'package:social_feed_app/presentation/stores/post_store/sync/sync_error_handler.dart';
import 'package:social_feed_app/presentation/stores/post_store/utils/post_store_helpers.dart';

// part 'post_store_base.g.dart';

abstract class PostStoreBase with Store {
  // Estado
  final PostStoreState state = PostStoreState();
  final PostStoreDependencies dependencies = PostStoreDependencies.create();
  
  // Computed properties
  late final PostStoreComputed computed;
  
  // Funcionalidades
  late final PostLoader loader;
  late final PostCreator creator;
  late final PostLiker liker;
  late final PostUpdater updater;
  late final PostDeleter deleter;
  late final PostCommenter commenter;
  
  // Sincronização
  late final OptimisticPostManager optimisticManager;
  late final SyncErrorHandler errorHandler;
  
  // Utilitários
  late final PostStoreHelpers helpers;

  PostStoreBase() {
    _initializeComponents();
  }

  void _initializeComponents() {
    computed = PostStoreComputed(
      posts: state.posts,
      optimisticPosts: state.optimisticPosts,
      currentUserId: state.currentUserId,
    );
    
    helpers = PostStoreHelpers(state, dependencies);
    errorHandler = SyncErrorHandler(state, helpers);
    optimisticManager = OptimisticPostManager(state, dependencies, helpers, errorHandler);
    
    loader = PostLoader(state, dependencies, helpers, computed);
    creator = PostCreator(state, dependencies, helpers, optimisticManager);
    liker = PostLiker(state, dependencies, helpers);
    updater = PostUpdater(state, dependencies, helpers);
    deleter = PostDeleter(state, dependencies, helpers, optimisticManager);
    commenter = PostCommenter(state, dependencies, helpers);
  }

  // ============ MÉTODOS PÚBLICOS (delegação) ============

  Future<void> loadPosts() => loader.loadPosts();
  Future<void> loadMorePosts() => loader.loadMorePosts();
  Future<void> refreshPosts() => loader.refreshPosts();
  
  Future<void> createPost(String content, {String? imagePath}) =>
      creator.createPost(content, imagePath: imagePath);
  
  Future<void> likePost(String postId) => liker.likePost(postId);
  
  Future<void> updatePost(String postId, String newContent) =>
      updater.updatePost(postId, newContent);
  
  Future<void> deletePost(String postId) => deleter.deletePost(postId);
  
  Future<void> addComment(String postId) => commenter.addComment(postId);
  
  Future<List<Post>> loadLikedPosts() => loader.loadLikedPosts();

  // ============ GETTERS ============

  List<Post> get allPosts => computed.allPosts;
  List<Post> get processingPosts => computed.processingPosts;
  List<Post> get sortedPosts => computed.sortedPosts;
  int get totalPosts => computed.totalPosts;
  int get totalLikes => computed.totalLikes;
  List<Post> get likedPosts => computed.likedPosts;
  int get userLikeCount => computed.userLikeCount;
  
  bool get isLoading => state.isLoading;
  bool get isLoadingMore => state.isLoadingMore;
  bool get hasMorePosts => state.hasMorePosts;
  String? get errorMessage => state.errorMessage;
  Post? get selectedPost => state.selectedPost;

  String? get currentUserId => state.currentUserId;

  // ============ SETTERS ============

  @action
  void setCurrentUserId(String userId) {
    state.currentUserId = userId;
  }

  @action
  void selectPost(Post post) {
    state.selectedPost = post;
  }

  @action
  void clearSelection() {
    state.selectedPost = null;
  }

  // ============ MÉTODOS AUXILIARES PÚBLICOS ============

  bool isPostLikedByUser(String postId) {
    if (state.currentUserId == null) return false;
    final post = helpers.findPostById(postId);
    return post?.likedBy.contains(state.currentUserId!) ?? false;
  }

  bool shouldShowLoading(String postId) {
    return state.processingPostIds.contains(postId);
  }

  Post? findPostById(String postId) {
    return helpers.findPostById(postId);
  }

  @action
  void fixAllPostsOptimisticFlags() {
    optimisticManager.fixAllPostsOptimisticFlags();
  }

  @action
  void emergencyResetAllOptimisticFlags() {
    optimisticManager.emergencyResetAllOptimisticFlags();
  }
}