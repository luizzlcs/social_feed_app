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

  @override
  void initState() {
    super.initState();
    _authStore = getIt<AuthStore>();
    _postStore = getIt<PostStore>();

    // Carrega os posts quando a tela é aberta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postStore.loadPosts();
    });
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
          // Botão para criar novo post
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

          if (_postStore.posts.isEmpty) {
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
            onRefresh: () => _postStore.loadPosts(),
            child: Column(
              children: [
                // Estatísticas rápidas
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

                // Lista de posts
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _postStore.sortedPosts.length,
                    itemBuilder: (context, index) {
                      final post = _postStore.sortedPosts[index];
                      return PostCard(
                        post: post,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailPage(postId: post.id),
                            ),
                          );
                        },
                        onLike: () => _postStore.likePost(post.id),
                        onComment: () => _postStore.addComment(post.id),
                        onEdit: () => _showEditPostDialog(post),
                        onDelete: () => _showDeletePostDialog(post.id),
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
          if (imagePath != null) {
            await _postStore.createPostWithImage(content, imagePath);
          } else {
            await _postStore.createPost(content);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    ),
  );
}

  void _showEditPostDialog(Post post) {
    final TextEditingController controller = TextEditingController(
      text: post.content,
    );

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
                  onPressed: _postStore.isLoading
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
                  onPressed: _postStore.isLoading
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
