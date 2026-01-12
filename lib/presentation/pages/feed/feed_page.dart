import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';
import 'package:social_feed_app/presentation/widgets/post_card.dart';
import 'package:social_feed_app/presentation/pages/post_detail/post_detail_page.dart';
import 'package:social_feed_app/presentation/pages/create_post/create_post_page.dart';

class FeedPage extends StatefulWidget {
  final String username;

  const FeedPage({super.key, required this.username});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final AuthStore _authStore;
  late final PostStore _postStore;

  final ScrollController _scrollController = ScrollController(); // ← NOVO

  @override
  void initState() {
    super.initState();
    _authStore = getIt<AuthStore>();
    _postStore = getIt<PostStore>();

    // Configurar listener para scroll infinito
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postStore.loadPosts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ← IMPORTANTE
    super.dispose();
  }

  // Método para detectar quando chegar no final da lista
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _postStore.loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_) {
            return Row(
              children: [
                const Text('Feed'),
                const SizedBox(width: 8),
                if (_postStore.totalPosts > 0)
                  Chip(
                    label: Text('${_postStore.totalPosts}'),
                    backgroundColor: Colors.white,
                  ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePostDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _authStore.logout,
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (_postStore.isLoading && _postStore.posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando posts...'),
                ],
              ),
            );
          }

          if (_postStore.errorMessage != null && _postStore.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    _postStore.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _postStore.loadPosts,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (_postStore.allPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.feed, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum post ainda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seja o primeiro a compartilhar algo!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showCreatePostDialog,
                    child: const Text('Criar primeiro post'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _postStore.refreshPosts(), // ← ATUALIZADO
            child: Column(
              children: [
                // Estatísticas
                Observer(
                  builder: (_) {
                    if (_postStore.totalPosts == 0) return const SizedBox();

                    return Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.blue[50],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${_postStore.totalPosts}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const Text(
                                'Posts',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${_postStore.totalLikes}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const Text(
                                'Curtidas',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Posts sendo processados
                Observer(
                  builder: (_) {
                    if (_postStore.processingPosts.isNotEmpty) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Sincronizando (${_postStore.processingPosts.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),

                // Lista de posts COM PAGINAÇÃO
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8),
                    itemCount:
                        _postStore.sortedPosts.length +
                        (_postStore.hasMorePosts || _postStore.isLoadingMore
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      // Se é o item de loading
                      if (index >= _postStore.sortedPosts.length) {
                        return Observer(
                          builder: (_) {
                            if (_postStore.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (_postStore.hasMorePosts) {
                              // Botão manual para carregar mais (fallback)
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: _postStore.loadMorePosts,
                                    child: const Text('Carregar mais posts'),
                                  ),
                                ),
                              );
                            }

                            return Container(); // Vazio se não tem mais posts
                          },
                        );
                      }

                      final post = _postStore.sortedPosts[index];
                      return PostCard(
                        post: post,
                        onTap: () {
                          if (!post.isOptimistic) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailPage(postId: post.id),
                              ),
                            );
                          }
                        },
                        onLike: () {
                          if (!post.isOptimistic) {
                            _postStore.likePost(post.id);
                          }
                        },
                        onComment: () {
                          if (!post.isOptimistic) {
                            _postStore.addComment(post.id);
                          }
                        },
                        onEdit: post.isOptimistic
                            ? null
                            : () => _showEditPostDialog(post),
                        onDelete: post.isOptimistic
                            ? null
                            : () => _showDeletePostDialog(post.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreatePostDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(
          onPostCreated: (content, imagePath) async {
            await _postStore.createPost(content, imagePath: imagePath);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post criado! Sincronizando...'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditPostDialog(Post post) {
    final controller = TextEditingController(text: post.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Post'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Edite seu post...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            Observer(
              builder: (_) {
                return ElevatedButton(
                  onPressed: _postStore.isLoading || _postStore.isLoadingMore
                      ? null
                      : () async {
                          if (controller.text.trim().isNotEmpty) {
                            await _postStore.updatePost(
                              post.id,
                              controller.text.trim(),
                            );
                            Navigator.pop(context);
                          }
                        },
                  child: const Text('Salvar'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeletePostDialog(String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Post'),
          content: const Text('Tem certeza que deseja excluir este post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            Observer(
              builder: (_) {
                return ElevatedButton(
                  onPressed: _postStore.isLoading || _postStore.isLoadingMore
                      ? null
                      : () async {
                          await _postStore.deletePost(postId);
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Excluir'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
