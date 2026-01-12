import 'package:cloud_firestore/cloud_firestore.dart';
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
  
  DocumentSnapshot? _lastDocument; // ← Movido para cá (era variável solta)

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

  // ============ COMPUTED PROPERTIES ============

  // Computed: Lista combinada de todos os posts
  @computed
  List<Post> get allPosts {
    final combined = <Post>[...posts, ...optimisticPosts];
    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final seenIds = <String>{};
    return combined.where((post) => seenIds.add(post.id)).toList();
  }

  // Computed: Posts que estão sendo processados
  @computed
  List<Post> get processingPosts => 
      optimisticPosts.where((post) => processingPostIds.contains(post.id)).toList();

  // Computed: Posts ordenados (igual a allPosts)
  @computed
  List<Post> get sortedPosts => allPosts;

  // Computed: Total de posts
  @computed
  int get totalPosts => allPosts.length;

  // Computed: Total de curtidas
  @computed
  int get totalLikes => allPosts.fold(0, (sum, post) => sum + post.likes);

  // ============ MÉTODOS PÚBLICOS ============

  /// Carrega posts do Firebase
  @action
  Future<void> loadPosts() async {
    isLoading = true;
    errorMessage = null;
    _lastDocument = null; // Reset na primeira carga

    try {
      final loadedPosts = await _repository.getPosts(limit: 10);
      
      // Remove posts otimistas que já foram sincronizados
      _removeSyncedOptimisticPosts(loadedPosts);

      posts.clear();
      posts.addAll(loadedPosts);
      
      // Salva último documento para paginação
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

  /// Carrega mais posts (pagination)
  @action
  Future<void> loadMorePosts() async {
    if (isLoading || isLoadingMore || !hasMorePosts) return;
    
    isLoadingMore = true;
    errorMessage = null;

    try {
      final loadedPosts = await _repository.getPosts(
        limit: 10,
        lastDocument: _lastDocument,
      );
      
      if (loadedPosts.isNotEmpty) {
        posts.addAll(loadedPosts);
        
        // Atualiza último documento
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

  /// Cria um novo post (com ou sem imagem)
  @action
  Future<void> createPost(String content, {String? imagePath}) async {
    try {
      // 1. Cria post otimista
      final optimisticPost = _createOptimisticPost(content, imagePath);
      optimisticPosts.insert(0, optimisticPost);
      processingPostIds.add(optimisticPost.id);

      // 2. Salva no Firebase em background
      _savePostInBackground(optimisticPost, imagePath);
      
    } catch (e) {
      errorMessage = 'Erro ao criar post: $e';
    }
  }

  /// Atualiza conteúdo de um post
  @action
  Future<void> updatePost(String postId, String newContent) async {
    // Atualiza imediatamente na UI
    _updatePostInList(posts, postId, newContent);
    _updatePostInList(optimisticPosts, postId, newContent);
    
    processingPostIds.add(postId);
    
    // Sincroniza com Firebase em background
    _updatePostInBackground(postId, newContent);
  }

  /// Deleta um post
  @action
  Future<void> deletePost(String postId) async {
    // Guarda cópia para possível rollback
    final postToRestore = _findPostById(postId);
    
    // Remove imediatamente da UI
    posts.removeWhere((post) => post.id == postId);
    optimisticPosts.removeWhere((post) => post.id == postId);
    
    processingPostIds.add(postId);
    
    // Deleta no Firebase em background
    _deletePostInBackground(postId, postToRestore);
  }

  /// Adiciona like a um post
  @action
  Future<void> likePost(String postId) async {
    // Incrementa imediatamente na UI
    _incrementLikeInList(posts, postId);
    _incrementLikeInList(optimisticPosts, postId);
    
    // Sincroniza com Firebase em background
    _likePostInBackground(postId);
  }

  /// Adiciona comentário a um post
  @action
  Future<void> addComment(String postId) async {
    // Incrementa imediatamente na UI
    _incrementCommentInList(posts, postId);
    _incrementCommentInList(optimisticPosts, postId);
    
    // Sincroniza com Firebase em background
    _addCommentInBackground(postId);
  }

  /// Seleciona um post para visualização/edição
  @action
  void selectPost(Post post) {
    selectedPost = post;
  }

  /// Limpa seleção atual
  @action
  void clearSelection() {
    selectedPost = null;
  }

  // ============ MÉTODOS PRIVADOS ============

  /// Obtém último documento para paginação
  Future<DocumentSnapshot?> _getLastDocumentSnapshot() async {
    if (posts.isEmpty) return null;
    
    try {
      final lastPost = posts.last;
      final doc = await _firebaseService.postsCollection.doc(lastPost.id).get();
      return doc;
    } catch (e) {
      return null;
    }
  }

  /// Cria post otimista para feedback imediato
  Post _createOptimisticPost(String content, String? imagePath) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    return Post(
      id: timestamp.toString(),
      userId: 'current_user', // Será substituído por AuthStore depois
      username: 'Você',
      content: content,
      imageUrl: imagePath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likes: 0,
      comments: 0,
      isOptimistic: true,
    );
  }

  /// Salva post no Firebase em background
  Future<void> _savePostInBackground(Post optimisticPost, String? imagePath) async {
    try {
      // Cria post real (sem flag otimista)
      final realPost = optimisticPost.copyWith(isOptimistic: false);
      
      final savedPost = await _repository.createPost(
        realPost,
        imagePath: imagePath,
      );

      // Atualiza post otimista com dados reais
      _updateOptimisticPostWithRealData(optimisticPost.id, savedPost);
      
    } catch (e) {
      // Marca como falhado
      _markOptimisticPostAsFailed(optimisticPost.id, e.toString());
    } finally {
      processingPostIds.remove(optimisticPost.id);
    }
  }

  /// Atualiza post otimista com dados reais do Firebase
  @action
  void _updateOptimisticPostWithRealData(String postId, Post realPost) {
    final index = optimisticPosts.indexWhere((post) => post.id == postId);
    
    if (index != -1) {
      // Substitui por post real
      optimisticPosts[index] = realPost;
      
      // Adiciona à lista principal se ainda não existir
      if (!posts.any((post) => post.id == postId)) {
        posts.insert(0, realPost);
      }
    }
  }

  /// Marca post otimista como falhado
  @action
  void _markOptimisticPostAsFailed(String postId, String error) {
    final index = optimisticPosts.indexWhere((post) => post.id == postId);
    
    if (index != -1) {
      final failedPost = optimisticPosts[index].copyWith(
        syncFailed: true,
        syncError: error,
      );
      
      optimisticPosts[index] = failedPost;
    }
  }

  /// Remove posts otimistas já sincronizados
  @action
  void _removeSyncedOptimisticPosts(List<Post> realPosts) {
    // Remove pelo ID
    final realPostIds = realPosts.map((post) => post.id).toSet();
    optimisticPosts.removeWhere((post) => realPostIds.contains(post.id));
    
    // Limpeza: remove posts otimistas antigos (> 5 minutos)
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5));
    optimisticPosts.removeWhere((post) => 
      post.isOptimistic && post.createdAt.isBefore(cutoffTime)
    );
  }

  // ============ HELPERS PARA ATUALIZAÇÃO DE LISTAS ============

  void _updatePostInList(ObservableList<Post> list, String postId, String newContent) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1) {
      list[index] = list[index].copyWith(
        content: newContent,
        updatedAt: DateTime.now(),
      );
    }
  }

  void _incrementLikeInList(ObservableList<Post> list, String postId) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1) {
      list[index] = list[index].copyWith(likes: list[index].likes + 1);
    }
  }

  void _incrementCommentInList(ObservableList<Post> list, String postId) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1) {
      list[index] = list[index].copyWith(comments: list[index].comments + 1);
    }
  }

  void _decrementLikeInList(ObservableList<Post> list, String postId) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1 && list[index].likes > 0) {
      list[index] = list[index].copyWith(likes: list[index].likes - 1);
    }
  }

  void _decrementCommentInList(ObservableList<Post> list, String postId) {
    final index = list.indexWhere((post) => post.id == postId);
    if (index != -1 && list[index].comments > 0) {
      list[index] = list[index].copyWith(comments: list[index].comments - 1);
    }
  }

  // ============ BACKGROUND SYNC METHODS ============

  Future<void> _updatePostInBackground(String postId, String newContent) async {
    try {
      final post = _findPostById(postId);
      if (post != null) {
        final updatedPost = post.copyWith(content: newContent);
        await _repository.updatePost(updatedPost);
      }
    } catch (e) {
      // Marca como falhado
      _markPostAsFailed(postId, 'Falha ao atualizar: $e');
    } finally {
      processingPostIds.remove(postId);
    }
  }

  Future<void> _deletePostInBackground(String postId, Post? postToRestore) async {
    try {
      await _repository.deletePost(postId);
    } catch (e) {
      // Rollback: restaura post se falhar
      if (postToRestore != null && !_postExists(postId)) {
        if (postToRestore.isOptimistic) {
          optimisticPosts.add(postToRestore);
        } else {
          posts.add(postToRestore);
        }
      }
    } finally {
      processingPostIds.remove(postId);
    }
  }

  Future<void> _likePostInBackground(String postId) async {
    try {
      // TODO: Obter userId real do AuthStore
      const userId = 'current_user';
      await _repository.likePost(postId, userId);
    } catch (e) {
      // Reverte like local
      _decrementLikeInList(posts, postId);
      _decrementLikeInList(optimisticPosts, postId);
    }
  }

  Future<void> _addCommentInBackground(String postId) async {
    try {
      // TODO: Obter userId real e comentário do usuário
      const userId = 'current_user';
      const comment = 'Novo comentário';
      await _repository.addComment(postId, userId, comment);
    } catch (e) {
      // Reverte contador local
      _decrementCommentInList(posts, postId);
      _decrementCommentInList(optimisticPosts, postId);
    }
  }

  // ============ HELPERS ============

  Post? _findPostById(String postId) {
    try {
      final post = posts.firstWhere(
        (post) => post.id == postId,
        orElse: () => throw Exception('Post não encontrado em posts'),
      );
      return post;
    } catch (_) {
      try {
        final post = optimisticPosts.firstWhere(
          (post) => post.id == postId,
          orElse: () => throw Exception('Post não encontrado em optimisticPosts'),
        );
        return post;
      } catch (_) {
        return null;
      }
    }
  }

  bool _postExists(String postId) {
    return posts.any((post) => post.id == postId) ||
           optimisticPosts.any((post) => post.id == postId);
  }

  void _markPostAsFailed(String postId, String error) {
    _updatePostSyncStatus(posts, postId, error);
    _updatePostSyncStatus(optimisticPosts, postId, error);
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