import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';

part 'post_store.g.dart';

class PostStore = _PostStoreBase with _$PostStore;

abstract class _PostStoreBase with Store {
  @observable
  ObservableList<Post> posts = ObservableList<Post>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  Post? selectedPost;

  // Action para carregar posts iniciais
  @action
  Future<void> loadPosts() async {
    isLoading = true;
    errorMessage = null;

    try {
      // Simula delay de rede
      await Future.delayed(const Duration(seconds: 1));

      // Posts de exemplo (depois virão de API/local storage)
      final examplePosts = [
        Post(
          id: '1',
          userId: 'user1',
          username: 'João Silva',
          content: 'Estou muito feliz com meu novo projeto em Flutter! 🚀',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          likes: 15,
          comments: 3,
          imageUrl: null,
        ),
        Post(
          id: '2',
          userId: 'user2',
          username: 'Maria Santos',
          content: 'Alguém tem dicas de lugares bons para estudar programação online?',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          likes: 8,
          comments: 7,
          imageUrl: null,
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
        ),
        Post(
          id: '4',
          userId: 'user4',
          username: 'Ana Oliveira',
          content: 'Dia produtivo hoje! Consegui resolver aquele bug que estava me atormentando há semanas. 💪',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          likes: 25,
          comments: 5,
          imageUrl: null,
        ),
        Post(
          id: '5',
          userId: 'user5',
          username: 'Carlos Mendes',
          content: 'Compartilhando um artigo muito interessante sobre arquitetura limpa em Flutter. Recomendo a leitura!',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          likes: 31,
          comments: 9,
          imageUrl: 'https://picsum.photos/400/300?random=2',
        ),
      ];

      posts.clear();
      posts.addAll(examplePosts);
    } catch (e) {
      errorMessage = 'Erro ao carregar posts: $e';
    } finally {
      isLoading = false;
    }
  }

  // Action para criar novo post
  @action
  Future<void> createPost(String content, {String? imageUrl}) async {
    isLoading = true;

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        username: 'Você',
        content: content,
        createdAt: DateTime.now(),
        likes: 0,
        comments: 0,
        imageUrl: imageUrl,
      );

      // Adiciona no início da lista (mais recente primeiro)
      posts.insert(0, newPost);
    } catch (e) {
      errorMessage = 'Erro ao criar post: $e';
    } finally {
      isLoading = false;
    }
  }

  // Action para atualizar post
  @action
  Future<void> updatePost(String postId, String newContent) async {
    isLoading = true;

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final updatedPost = posts[index].copyWith(content: newContent);
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
      await Future.delayed(const Duration(milliseconds: 300));
      posts.removeWhere((post) => post.id == postId);
    } catch (e) {
      errorMessage = 'Erro ao deletar post: $e';
    } finally {
      isLoading = false;
    }
  }

  // Action para curtir post
  @action
  void likePost(String postId) {
    final index = posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = posts[index];
      final updatedPost = post.copyWith(likes: post.likes + 1);
      posts[index] = updatedPost;
    }
  }

  // Action para adicionar comentário
  @action
  void addComment(String postId) {
    final index = posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = posts[index];
      final updatedPost = post.copyWith(comments: post.comments + 1);
      posts[index] = updatedPost;
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

  // Computed: posts ordenados por data (mais recente primeiro)
  @computed
  List<Post> get sortedPosts => posts.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Computed: total de posts
  @computed
  int get totalPosts => posts.length;

  // Computed: total de curtidas em todos os posts
  @computed
  int get totalLikes => posts.fold(0, (sum, post) => sum + post.likes);
}