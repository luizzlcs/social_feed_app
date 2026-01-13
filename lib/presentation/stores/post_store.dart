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
  
  final Map<String, Completer<void>> _likeCompleters = {};
  final Map<String, DateTime> _processingStartTimes = {};

  _PostStoreBase() 
    : _repository = FirebasePostRepository(getIt<FirebaseService>()),
      _firebaseService = getIt<FirebaseService>();

  @observable
  ObservableList<Post> posts = ObservableList<Post>();

  @observable
  ObservableList<Post> optimisticPosts = ObservableList<Post>();

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

  @action
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  /// ✅ MODIFICADO: Adiciona correção de flags
  @action
  Future<void> loadPosts() async {
    isLoading = true;
    errorMessage = null;
    _lastDocument = null;

    _cleanupStaleProcessing();

    try {
      final loadedPosts = await _repository.getPosts(
        limit: 10,
        currentUserId: _currentUserId,
      );
      
      _removeSyncedOptimisticPosts(loadedPosts);
      posts.clear();
      posts.addAll(loadedPosts);
      
      // ✅ ADICIONADO: Corrige flags isOptimistic incorretas
      _fixPostsOptimisticFlags();
      
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
        
        // ✅ ADICIONADO: Corrige flags dos novos posts
        _fixPostsOptimisticFlags();
        
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

  @action
  Future<void> refreshPosts() async {
    isLoading = true;
    _lastDocument = null;
    await loadPosts();
  }

  @action
  Future<void> createPost(String content, {String? imagePath}) async {
    try {
      final optimisticPost = _createOptimisticPost(content, imagePath);
      optimisticPosts.insert(0, optimisticPost);
      processingPostIds.add(optimisticPost.id);
      
      _processingStartTimes[optimisticPost.id] = DateTime.now();

      _savePostInBackground(optimisticPost, imagePath);
    } catch (e) {
      errorMessage = 'Erro ao criar post: $e';
    }
  }

  @action
  Future<void> likePost(String postId) async {
    if (_currentUserId == null) return;

    if (_likeCompleters.containsKey(postId)) {
      return;
    }

    final post = findPostById(postId);
    if (post == null) return;

    final alreadyLiked = post.likedBy.contains(_currentUserId!);
    final newState = !alreadyLiked;
    
    _toggleLikeInList(posts, postId, _currentUserId!, newState);
    _toggleLikeInList(optimisticPosts, postId, _currentUserId!, newState);
    
    _toggleLikeInBackground(postId, _currentUserId!, newState);
  }

  /// ✅ MODIFICADO: Atualização silenciosa sem feedback visual
  @action
  Future<void> updatePost(String postId, String newContent) async {
    // 1. Atualiza UI localmente imediatamente
    _updatePostInList(posts, postId, newContent);
    _updatePostInList(optimisticPosts, postId, newContent);
    
    // ✅ NÃO adiciona ao processingPostIds para edições
    // Isso evita mostrar "Enviando..." para atualizações
    
    // 2. Sincroniza em background silenciosamente
    unawaited(_updatePostInBackground(postId, newContent));
  }

  @action
  Future<void> deletePost(String postId) async {
    final postToRestore = findPostById(postId);
    
    posts.removeWhere((post) => post.id == postId);
    optimisticPosts.removeWhere((post) => post.id == postId);
    
    processingPostIds.add(postId);
    _processingStartTimes[postId] = DateTime.now();
    _deletePostInBackground(postId, postToRestore);
  }

  @action
  Future<void> addComment(String postId) async {
    _incrementCommentInList(posts, postId);
    _incrementCommentInList(optimisticPosts, postId);
    
    _addCommentInBackground(postId);
  }

  @action
  void selectPost(Post post) {
    selectedPost = post;
  }

  @action
  void clearSelection() {
    selectedPost = null;
  }

  bool isPostLikedByUser(String postId) {
    if (_currentUserId == null) return false;
    final post = findPostById(postId);
    return post?.likedBy.contains(_currentUserId!) ?? false;
  }

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

  // ============ NOVOS MÉTODOS DE CORREÇÃO ============

  /// ✅ NOVO: Corrige flags isOptimistic em todos os posts
  @action
  void _fixPostsOptimisticFlags() {
    if (kDebugMode) {
      print('🔧 [PostStore] Corrigindo flags isOptimistic...');
    }
    
    int correctedCount = 0;
    
    // Corrige posts na lista principal (posts do Firebase)
    for (var i = 0; i < posts.length; i++) {
      final post = posts[i];
      
      // Se o post tem isOptimistic=true mas não está sendo processado,
      // então é um post do Firebase com flag incorreta
      if (post.isOptimistic && !processingPostIds.contains(post.id)) {
        posts[i] = post.copyWith(isOptimistic: false);
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

  /// ✅ NOVO: Método público para correção manual
  @action
  void fixAllPostsOptimisticFlags() {
    print('🛠️ [PostStore] Correção manual de flags isOptimistic iniciada');
    _fixPostsOptimisticFlags();
    
    // Também limpa posts otimistas antigos
    _cleanupOldOptimisticPosts();
    
    print('✅ [PostStore] Correção manual completa');
  }

  /// ✅ NOVO: Correção de emergência - força todos posts para isOptimistic=false
  @action
  void emergencyResetAllOptimisticFlags() {
    print('🚨 [PostStore] EMERGÊNCIA: Resetando todas as flags isOptimistic!');
    
    int resetCount = 0;
    
    // Resetar todos os posts na lista principal
    for (var i = 0; i < posts.length; i++) {
      if (posts[i].isOptimistic) {
        posts[i] = posts[i].copyWith(isOptimistic: false);
        resetCount++;
      }
    }
    
    // Resetar posts otimistas (exceto os que estão sendo processados)
    for (var i = 0; i < optimisticPosts.length; i++) {
      final post = optimisticPosts[i];
      if (post.isOptimistic && !processingPostIds.contains(post.id)) {
        optimisticPosts[i] = post.copyWith(isOptimistic: false);
        resetCount++;
      }
    }
    
    // Limpar processamentos antigos
    _cleanupOldOptimisticPosts();
    
    print('✅ [PostStore] Reset completo!');
    print('   - Posts resetados: $resetCount');
    print('   - Posts otimistas: ${optimisticPosts.length}');
    print('   - Posts sendo processados: ${processingPostIds.length}');
  }

  /// ✅ NOVO: Limpa posts otimistas antigos
  @action
  void _cleanupOldOptimisticPosts() {
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5));
    final oldPosts = optimisticPosts
        .where((post) => post.isOptimistic && post.createdAt.isBefore(cutoffTime))
        .toList();
    
    for (final post in oldPosts) {
      optimisticPosts.remove(post);
      processingPostIds.remove(post.id);
      _processingStartTimes.remove(post.id);
      
      if (kDebugMode) {
        print('🗑️ Removido post otimista antigo: ${post.id}');
      }
    }
  }

  /// ✅ MODIFICADO: Verifica se deve mostrar loading
  bool shouldShowLoading(String postId) {
    // ✅ CORREÇÃO: Mostra loading apenas se está sendo processado AGORA
    return processingPostIds.contains(postId);
  }

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
      
      final post = findPostById(id);
      if (post != null && post.isOptimistic) {
        _markOptimisticPostAsFailed(id, 'Timeout: sincronização excedeu 30 segundos');
      }
    }
  }

  // ============ MÉTODOS PRIVADOS ============

  Future<DocumentSnapshot?> _getLastDocumentSnapshot() async {
    if (posts.isEmpty) return null;
    
    try {
      final lastPost = posts.last;
      return await _firebaseService.postsCollection.doc(lastPost.id).get();
    } catch (e) {
      return null;
    }
  }

  Post _createOptimisticPost(String content, String? imagePath) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    return Post(
      // ✅ Use prefixo para identificar posts otimistas
      id: 'temp_${timestamp}_${_currentUserId ?? 'unknown'}',
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

  Future<void> _savePostInBackground(Post optimisticPost, String? imagePath) async {
    try {
      final realPost = optimisticPost.copyWith(isOptimistic: false);
      final savedPost = await _repository.createPost(realPost, imagePath: imagePath);
      _updateOptimisticPostWithRealData(optimisticPost.id, savedPost);
    } catch (e) {
      _markOptimisticPostAsFailed(optimisticPost.id, e.toString());
    } finally {
      processingPostIds.remove(optimisticPost.id);
      _processingStartTimes.remove(optimisticPost.id);
    }
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
      await _repository.toggleLike(postId, userId);
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      
      Future.delayed(const Duration(seconds: 2), () {
        final currentPost = findPostById(postId);
        if (currentPost != null) {
          final currentState = currentPost.likedBy.contains(userId);
          if (currentState == isLiking) {
            _toggleLikeInList(posts, postId, userId, !isLiking);
            _toggleLikeInList(optimisticPosts, postId, userId, !isLiking);
            
            if (kDebugMode) {
              print('❌ Curtida revertida silenciosamente para post $postId');
            }
          }
        }
      });
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        _likeCompleters.remove(postId);
      });
    }
  }

  /// ✅ MODIFICADO: Garante que post sincronizado não seja otimista
  @action
  void _updateOptimisticPostWithRealData(String postId, Post realPost) {
    final index = optimisticPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      // ✅ CRÍTICO: Garantir que o post real NÃO seja otimista
      final synchronizedPost = realPost.copyWith(
        isOptimistic: false,
        syncFailed: false,
        syncError: null,
      );
      
      optimisticPosts[index] = synchronizedPost;
      
      processingPostIds.remove(postId);
      _processingStartTimes.remove(postId);
      
      if (!posts.any((post) => post.id == postId)) {
        posts.insert(0, synchronizedPost);
      }
    }
  }

  @action
  void _markOptimisticPostAsFailed(String postId, String error) {
    final index = optimisticPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      optimisticPosts[index] = optimisticPosts[index].copyWith(
        syncFailed: true,
        syncError: error,
      );
      
      processingPostIds.remove(postId);
      _processingStartTimes.remove(postId);
    }
  }

  /// ✅ MODIFICADO: Também corrige flags ao remover posts sincronizados
  @action
  void _removeSyncedOptimisticPosts(List<Post> realPosts) {
    final realPostIds = realPosts.map((post) => post.id).toSet();
    
    processingPostIds.removeWhere((id) => realPostIds.contains(id));
    
    realPostIds.forEach((id) {
      _processingStartTimes.remove(id);
    });
    
    optimisticPosts.removeWhere((post) => realPostIds.contains(post.id));
    
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

  /// ✅ MODIFICADO: Atualização silenciosa - não mostra loading
  Future<void> _updatePostInBackground(String postId, String newContent) async {
    try {
      final post = findPostById(postId);
      if (post != null) {
        await _repository.updatePost(post.copyWith(content: newContent));
        
        // ✅ Sucesso silencioso
        if (kDebugMode) {
          print('✅ Post $postId atualizado com sucesso (silenciosamente)');
        }
      }
    } catch (e) {
      // ✅ Erro silencioso - apenas log
      if (kDebugMode) {
        print('❌ Erro ao atualizar post $postId: $e');
      }
    }
    // ✅ NÃO remove de processingPostIds porque nunca foi adicionado
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
      _processingStartTimes.remove(postId);
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

  Post? findPostById(String postId) {
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