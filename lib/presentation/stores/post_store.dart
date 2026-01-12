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
  
  _PostStoreBase() : _repository = FirebasePostRepository(getIt<FirebaseService>());

  @observable
  ObservableList<Post> posts = ObservableList<Post>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  Post? selectedPost;

  @observable
  bool hasMorePosts = true;

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;

  // Action para carregar posts do Firebase
  @action
  Future<void> loadPosts() async {
    isLoading = true;
    errorMessage = null;

    try {
      final loadedPosts = await _repository.getPosts(limit: 10);
      
      posts.clear();
      posts.addAll(loadedPosts);
      
      // Atualiza o último documento para paginação
      if (loadedPosts.isNotEmpty) {
        hasMorePosts = loadedPosts.length == 10;
      } else {
        hasMorePosts = false;
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar posts: $e';
      // Fallback para dados mock se Firebase falhar
      _loadMockPosts();
    } finally {
      isLoading = false;
    }
  }

  // Action para carregar mais posts (pagination)
  @action
  Future<void> loadMorePosts() async {
    if (isLoading || !hasMorePosts) return;

    isLoading = true;

    try {
      final loadedPosts = await _repository.getPosts(
        limit: 10,
        lastDoc: _lastDocument,
      );
      
      if (loadedPosts.isNotEmpty) {
        posts.addAll(loadedPosts);
        hasMorePosts = loadedPosts.length == 10;
      } else {
        hasMorePosts = false;
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar mais posts: $e';
    } finally {
      isLoading = false;
    }
  }

  // Action para criar post com imagem
  @action
  Future<void> createPostWithImage(String content, String? imagePath) async {
    isLoading = true;
    errorMessage = null;

    try {
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id', // Depois vamos pegar do Firebase Auth
        username: 'Você', // Depois vamos pegar do usuário logado
        content: content,
        createdAt: DateTime.now(),
        // updatedAt: DateTime.now(),
        likes: 0,
        comments: 0,
        imageUrl: null, // Será preenchido pelo repository
        updatedAt: DateTime.now()
      );

      final createdPost = await _repository.createPost(newPost, imagePath: imagePath);
      
      // Adiciona no início da lista
      posts.insert(0, createdPost);
    } catch (e) {
      errorMessage = 'Erro ao criar post: $e';
    } finally {
      isLoading = false;
    }
  }

  // Action para criar post sem imagem
  @action
  Future<void> createPost(String content) async {
    await createPostWithImage(content, null);
  }

  // Action para atualizar post
  @action
  Future<void> updatePost(String postId, String newContent) async {
    isLoading = true;

    try {
      final index = posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final updatedPost = posts[index].copyWith(
          content: newContent,
          // updatedAt: DateTime.now(),
        );
        
        await _repository.updatePost(updatedPost);
        posts[index] = updatedPost;
      }
    } catch (e) {
      errorMessage = 'Erro ao atualizar post: $e';
    } finally {
      isLoading = false;
    }
  }

  // Action para deletar post
  @action
  Future<void> deletePost(String postId) async {
    isLoading = true;

    try {
      await _repository.deletePost(postId);
      posts.removeWhere((post) => post.id == postId);
    } catch (e) {
      errorMessage = 'Erro ao deletar post: $e';
    } finally {
      isLoading = false;
    }
  }

  // Action para curtir post
  @action
  Future<void> likePost(String postId) async {
    try {
      final index = posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = posts[index];
        final updatedPost = post.copyWith(likes: post.likes + 1);
        
        // Atualiza no Firebase (precisa do userId real)
        // await _repository.likePost(postId, 'current_user_id');
        
        posts[index] = updatedPost;
      }
    } catch (e) {
      errorMessage = 'Erro ao curtir post: $e';
    }
  }

  // Action para adicionar comentário
  @action
  Future<void> addComment(String postId) async {
    try {
      final index = posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = posts[index];
        final updatedPost = post.copyWith(comments: post.comments + 1);
        
        posts[index] = updatedPost;
      }
    } catch (e) {
      errorMessage = 'Erro ao adicionar comentário: $e';
    }
  }

  // Action para selecionar post
  @action
  void selectPost(Post post) {
    selectedPost = post;
  }

  // Action para limpar seleção
  @action
  void clearSelection() {
    selectedPost = null;
  }

  // Computed: posts ordenados por data
  @computed
  List<Post> get sortedPosts => posts.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Computed: total de posts
  @computed
  int get totalPosts => posts.length;

  // Computed: total de curtidas
  @computed
  int get totalLikes => posts.fold(0, (sum, post) => sum + post.likes);

  // Método de fallback (mock data)
  void _loadMockPosts() {
    final examplePosts = [
      Post(
        id: '1',
        userId: 'user1',
        username: 'João Silva',
        content: 'Estou muito feliz com meu novo projeto em Flutter! 🚀',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 15,
        comments: 3,
        updatedAt: DateTime.now()
      ),
      Post(
        id: '2',
        userId: 'user2',
        username: 'Maria Santos',
        content: 'Alguém tem dicas de lugares bons para estudar programação online?',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 8,
        comments: 7,
        imageUrl: 'https://picsum.photos/400/300?random=1',
        updatedAt: DateTime.now()
      ),
      Post(
        id: '3',
        userId: 'user3',
        username: 'Pedro Costa',
        content: 'Acabei de terminar meu primeiro app mobile! 😎\n\nFoi uma jornada incrível de aprendizado.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 42,
        comments: 12,
        imageUrl: 'https://picsum.photos/400/300?random=1',
        updatedAt: DateTime.now()
      ),
    ];

    posts.clear();
    posts.addAll(examplePosts);
  }

  // Stream de posts em tempo real
  Stream<List<Post>> get postsStream {
    return _repository.getPostsStream();
  }
}