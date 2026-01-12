import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/data/repository/firebase_post_repository.dart';
import 'package:social_feed_app/domain/entities/post.dart';

part 'post_store.g.dart';

class PostStore = _PostStoreBase with _$PostStore;

abstract class _PostStoreBase with Store {
  final FirebasePostRepository _repository;
  final FirebaseService _firebaseService;
  
  DocumentSnapshot? _lastDocument;
  String? _currentUserId;
  
  // ✅ Mapa para controlar curtidas em andamento
  final Map<String, Completer<void>> _likeCompleters = {};
  
  // ✅ NOVO: Mapa para registrar quando começou o processamento de cada post
  final Map<String, DateTime> _processingStartTimes = {};

  _PostStoreBase() 
    : _repository = FirebasePostRepository(getIt<FirebaseService>()),
      _firebaseService = getIt<FirebaseService>();

  // Observable: Posts carregados do Firebase
  @observable
  ObservableList<Post> posts = ObservableList<Post>();

  // Observable: Posts otimistas (criados localmente antes de sincronizar)
  @observable
  ObservableList<Post> optimisticPosts = ObservableList<Post>();

  // Observable: IDs de posts sendo processados
  @observable
  ObservableSet<String> processingPostIds = ObservableSet<String>();

  @observable
  bool isLoadingMore = false;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  Post? selectedPost;

  @observable
  bool hasMorePosts = true;

  String? get currentUserId => _currentUserId;

  // ============ COMPUTED PROPERTIES ============

  @computed
  List<Post> get allPosts {
    final combined = <Post>[...posts, ...optimisticPosts];
    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final seenIds = <String>{};
    return combined.where((post) => seenIds.add(post.id)).toList();
  }

  @computed
  List<Post> get processingPosts => 
      optimisticPosts.where((post) => processingPostIds.contains(post.id)).toList();

  @computed
  List<Post> get sortedPosts => allPosts;

  @computed
  int get totalPosts => allPosts.length;

  @computed
  int get totalLikes => allPosts.fold(0, (sum, post) => sum + post.likes);

  @computed
  List<Post> get likedPosts => 
      allPosts.where((post) => post.likedBy.contains(_currentUserId)).toList();

  @computed
  int get userLikeCount => 
      allPosts.where((post) => post.likedBy.contains(_currentUserId)).length;

  // ============ MÉTODOS PÚBLICOS ============

  /// Define o ID do usuário atual
  @action
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  /// Carrega posts do Firebase
  @action
  Future<void> loadPosts() async {
    isLoading = true;
    errorMessage = null;
    _lastDocument = null;

    // ✅ NOVO: Limpa processamentos pendentes antigos
    _cleanupStaleProcessing();

    try {
      final loadedPosts = await _repository.getPosts(
        limit: 10,
        currentUserId: _currentUserId,
      );
      
      _removeSyncedOptimisticPosts(loadedPosts);
      posts.clear();
      posts.addAll(loadedPosts);
      
      if (loadedPosts.isNotEmpty) {
        final lastDoc = await _getLastDocumentSnapshot();
        _lastDocument = lastDoc;
        hasMorePosts = loadedPosts.length == 10;
      } else {
        hasMorePosts = false;
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar posts: $e';
    } finally {
      isLoading = false;
    }
  }

  /// Carrega mais posts
  @action
  Future<void> loadMorePosts() async {
    if (isLoading || isLoadingMore || !hasMorePosts) return;
    
    isLoadingMore = true;
    errorMessage = null;

    try {
      final loadedPosts = await _repository.getPosts(
        limit: 10,
        lastDocument: _lastDocument,
        currentUserId: _currentUserId,
      );
      
      if (loadedPosts.isNotEmpty) {
        posts.addAll(loadedPosts);
        
        if (loadedPosts.isNotEmpty) {
          final lastDoc = await _getLastDocumentSnapshot();
          _lastDocument = lastDoc;
        }
        
        hasMorePosts = loadedPosts.length == 10;
      } else {
        hasMorePosts = false;
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar mais posts: $e';
    } finally {
      isLoadingMore = false;
    }
  }

  /// Atualiza lista de posts
  @action
  Future<void> refreshPosts() async {
    isLoading = true;
    _lastDocument = null;
    await loadPosts();
  }

  /// Cria um novo post
  @action
  Future<void> createPost(String content, {String? imagePath}) async {
    try {
      final optimisticPost = _createOptimisticPost(content, imagePath);
      optimisticPosts.insert(0, optimisticPost);
      processingPostIds.add(optimisticPost.id);
      
      // ✅ NOVO: Registra quando começou o processamento
      _processingStartTimes[optimisticPost.id] = DateTime.now();

      _savePostInBackground(optimisticPost, imagePath);
    } catch (e) {
      errorMessage = 'Erro ao criar post: $e';
    }
  }

  /// Curtir/Descurtir post INSTANTÂNEO
  @action
  Future<void> likePost(String postId) async {
    if (_currentUserId == null) return;

    // ✅ Verifica se já está processando esta curtida
    if (_likeCompleters.containsKey(postId)) {
      return; // Já está processando, ignora nova chamada
    }

    final post = _findPostById(postId);
    if (post == null) return;

    // Verifica estado atual
    final alreadyLiked = post.likedBy.contains(_currentUserId!);
    final newState = !alreadyLiked;
    
    // ✅ 1. Atualiza UI IMEDIATAMENTE
    _toggleLikeInList(posts, postId, _currentUserId!, newState);
    _toggleLikeInList(optimisticPosts, postId, _currentUserId!, newState);
    
    // ✅ 2. Inicia sync em background SEM BLOQUEAR
    _toggleLikeInBackground(postId, _currentUserId!, newState);
  }

  /// Atualiza conteúdo de um post
  @action
  Future<void> updatePost(String postId, String newContent) async {
    _updatePostInList(posts, postId, newContent);
    _updatePostInList(optimisticPosts, postId, newContent);
    
    processingPostIds.add(postId);
    _processingStartTimes[postId] = DateTime.now(); // ✅ NOVO
    _updatePostInBackground(postId, newContent);
  }

  /// Deleta um post
  @action
  Future<void> deletePost(String postId) async {
    final postToRestore = _findPostById(postId);
    
    posts.removeWhere((post) => post.id == postId);
    optimisticPosts.removeWhere((post) => post.id == postId);
    
    processingPostIds.add(postId);
    _processingStartTimes[postId] = DateTime.now(); // ✅ NOVO
    _deletePostInBackground(postId, postToRestore);
  }

  /// Adiciona comentário
  @action
  Future<void> addComment(String postId) async {
    _incrementCommentInList(posts, postId);
    _incrementCommentInList(optimisticPosts, postId);
    
    _addCommentInBackground(postId);
  }

  /// Seleciona um post
  @action
  void selectPost(Post post) {
    selectedPost = post;
  }

  /// Limpa seleção
  @action
  void clearSelection() {
    selectedPost = null;
  }

  /// Verifica se usuário curtiu um post
  bool isPostLikedByUser(String postId) {
    if (_currentUserId == null) return false;
    final post = _findPostById(postId);
    return post?.likedBy.contains(_currentUserId!) ?? false;
  }

  /// Carrega posts curtidos pelo usuário
  @action
  Future<List<Post>> loadLikedPosts() async {
    if (_currentUserId == null) {
      errorMessage = 'Usuário não identificado';
      return [];
    }
    
    try {
      return await _repository.getPostsLikedByUser(_currentUserId!);
    } catch (e) {
      errorMessage = 'Erro ao carregar posts curtidos: $e';
      return [];
    }
  }

  // ============ NOVOS MÉTODOS ADICIONADOS ============

  /// ✅ NOVO: Limpa processamentos pendentes antigos
  @action
  void _cleanupStaleProcessing() {
    final cutoffTime = DateTime.now().subtract(const Duration(seconds: 30));
    
    final staleIds = processingPostIds.where((id) {
      final startTime = _processingStartTimes[id];
      return startTime != null && startTime.isBefore(cutoffTime);
    }).toList();
    
    for (final id in staleIds) {
      processingPostIds.remove(id);
      _processingStartTimes.remove(id);
      
      // Marca como falhado se for post otimista
      final post = _findPostById(id);
      if (post != null && post.isOptimistic) {
        _markOptimisticPostAsFailed(id, 'Timeout: sincronização excedeu 30 segundos');
      }
    }
  }

  /// ✅ NOVO: Verifica se deve mostrar loading para um post
  bool shouldShowLoading(String postId) {
    // Não mostra loading se o post não é otimista
    final post = _findPostById(postId);
    if (post != null && !post.isOptimistic) {
      return false;
    }
    
    // Mostra loading apenas se está em processingPostIds
    return processingPostIds.contains(postId);
  }

  // ============ MÉTODOS PRIVADOS ============

  /// Obtém último documento para paginação
  Future<DocumentSnapshot?> _getLastDocumentSnapshot() async {
    if (posts.isEmpty) return null;
    
    try {
      final lastPost = posts.last;
      return await _firebaseService.postsCollection.doc(lastPost.id).get();
    } catch (e) {
      return null;
    }
  }

  /// Cria post otimista
  Post _createOptimisticPost(String content, String? imagePath) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    return Post(
      id: timestamp.toString(),
      userId: _currentUserId ?? 'unknown_user',
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

  /// Salva post no Firebase
  Future<void> _savePostInBackground(Post optimisticPost, String? imagePath) async {
    try {
      final realPost = optimisticPost.copyWith(isOptimistic: false);
      final savedPost = await _repository.createPost(realPost, imagePath: imagePath);
      _updateOptimisticPostWithRealData(optimisticPost.id, savedPost);
    } catch (e) {
      _markOptimisticPostAsFailed(optimisticPost.id, e.toString());
    } finally {
      processingPostIds.remove(optimisticPost.id);
      _processingStartTimes.remove(optimisticPost.id); // ✅ NOVO
    }
  }

  /// Alterna curtida em uma lista
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

  /// Sincroniza curtida SEM BLOQUEAR UI
  Future<void> _toggleLikeInBackground(
    String postId, 
    String userId, 
    bool isLiking,
  ) async {
    // ✅ Cria completer para controlar esta operação
    final completer = Completer<void>();
    _likeCompleters[postId] = completer;
    
    try {
      await _repository.toggleLike(postId, userId);
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      
      // ✅ Reverte SILENCIOSAMENTE após delay (usuário não percebe)
      Future.delayed(const Duration(seconds: 2), () {
        // Verifica se ainda precisa reverter
        final currentPost = _findPostById(postId);
        if (currentPost != null) {
          final currentState = currentPost.likedBy.contains(userId);
          if (currentState == isLiking) { // Se ainda está no estado que tentamos
            _toggleLikeInList(posts, postId, userId, !isLiking);
            _toggleLikeInList(optimisticPosts, postId, userId, !isLiking);
            
            // ✅ Opcional: Mostra erro discreto apenas no console
            if (kDebugMode) {
              print('❌ Curtida revertida silenciosamente para post $postId');
            }
          }
        }
      });
    } finally {
      // ✅ Remove completer após operação (com delay para evitar duplicação rápida)
      Future.delayed(const Duration(milliseconds: 500), () {
        _likeCompleters.remove(postId);
      });
    }
  }

  /// Atualiza post otimista
  @action
  void _updateOptimisticPostWithRealData(String postId, Post realPost) {
    final index = optimisticPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      optimisticPosts[index] = realPost;
      
      // ✅ NOVO: Remove do processingPostIds e do mapa de tempos
      processingPostIds.remove(postId);
      _processingStartTimes.remove(postId);
      
      if (!posts.any((post) => post.id == postId)) {
        posts.insert(0, realPost);
      }
    }
  }

  /// Marca como falhado
  @action
  void _markOptimisticPostAsFailed(String postId, String error) {
    final index = optimisticPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      optimisticPosts[index] = optimisticPosts[index].copyWith(
        syncFailed: true,
        syncError: error,
      );
      
      // ✅ NOVO: Remove do processing mesmo falhando
      processingPostIds.remove(postId);
      _processingStartTimes.remove(postId);
    }
  }

  /// Remove posts sincronizados (MODIFICADO)
  @action
  void _removeSyncedOptimisticPosts(List<Post> realPosts) {
    final realPostIds = realPosts.map((post) => post.id).toSet();
    
    // ✅ NOVO: REMOVE do processingPostIds também
    processingPostIds.removeWhere((id) => realPostIds.contains(id));
    
    // ✅ NOVO: Remove do mapa de tempos
    realPostIds.forEach((id) {
      _processingStartTimes.remove(id);
    });
    
    // Remove dos optimisticPosts
    optimisticPosts.removeWhere((post) => realPostIds.contains(post.id));
    
    // Remove posts otimistas antigos
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5));
    optimisticPosts.removeWhere((post) => 
      post.isOptimistic && post.createdAt.isBefore(cutoffTime)
    );
  }

  // ============ HELPERS ============

  void _updatePostInList(ObservableList<Post> list, String postId, String newContent) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1) {
      list[index] = list[index].copyWith(
        content: newContent,
        updatedAt: DateTime.now(),
      );
    }
  }

  void _incrementCommentInList(ObservableList<Post> list, String postId) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1) {
      list[index] = list[index].copyWith(comments: list[index].comments + 1);
    }
  }

  // ============ BACKGROUND SYNC ============

  Future<void> _updatePostInBackground(String postId, String newContent) async {
    try {
      final post = _findPostById(postId);
      if (post != null) {
        await _repository.updatePost(post.copyWith(content: newContent));
      }
    } catch (e) {
      _markPostAsFailed(postId, 'Falha ao atualizar: $e');
    } finally {
      processingPostIds.remove(postId);
      _processingStartTimes.remove(postId); // ✅ NOVO
    }
  }

  Future<void> _deletePostInBackground(String postId, Post? postToRestore) async {
    try {
      await _repository.deletePost(postId);
    } catch (e) {
      if (postToRestore != null && !_postExists(postId)) {
        if (postToRestore.isOptimistic) {
          optimisticPosts.add(postToRestore);
        } else {
          posts.add(postToRestore);
        }
      }
    } finally {
      processingPostIds.remove(postId);
      _processingStartTimes.remove(postId); // ✅ NOVO
    }
  }

  Future<void> _addCommentInBackground(String postId) async {
    try {
      if (_currentUserId != null) {
        const comment = 'Novo comentário';
        await _repository.addComment(postId, _currentUserId!, comment);
      }
    } catch (e) {
      _decrementCommentInList(posts, postId);
      _decrementCommentInList(optimisticPosts, postId);
    }
  }

  void _decrementCommentInList(ObservableList<Post> list, String postId) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1 && list[index].comments > 0) {
      list[index] = list[index].copyWith(comments: list[index].comments - 1);
    }
  }

  void _markPostAsFailed(String postId, String error) {
    _updatePostSyncStatus(posts, postId, error);
    _updatePostSyncStatus(optimisticPosts, postId, error);
    
    // ✅ NOVO: Remove do processing mesmo falhando
    processingPostIds.remove(postId);
    _processingStartTimes.remove(postId);
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

  // ============ HELPERS FINAIS ============

  Post? _findPostById(String postId) {
    try {
      return posts.firstWhere((post) => post.id == postId);
    } catch (_) {
      try {
        return optimisticPosts.firstWhere((post) => post.id == postId);
      } catch (_) {
        return null;
      }
    }
  }

  bool _postExists(String postId) {
    return posts.any((post) => post.id == postId) ||
           optimisticPosts.any((post) => post.id == postId);
  }
}