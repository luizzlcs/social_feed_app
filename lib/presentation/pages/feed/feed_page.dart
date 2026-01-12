import 'package:flutter/foundation.dart';
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
          // ✅ NOVO: Estado de loading melhorado
          if (_postStore.isLoading && _postStore.posts.isEmpty) {
            return _buildLoadingState();
          }

          // ✅ NOVO: Estado de erro melhorado
          if (_postStore.errorMessage != null && _postStore.posts.isEmpty) {
            return _buildErrorState();
          }

          if (_postStore.posts.isEmpty) {
            return _buildEmptyState();
          }

          return _buildFeedContent();
        },
      ),
    );
  }

  // ✅ NOVO: Método para estado de loading
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 20),
          const Text(
            'Carregando posts...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conectando ao Firebase',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          if (kDebugMode)
            Text(
              'Firestore: postsCollection',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ NOVO: Método para estado de erro
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Erro de conexão',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _postStore.errorMessage ??
                    'Não foi possível carregar os posts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _postStore.loadPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Opcional: Mostrar detalhes do erro em debug
                if (kDebugMode) {
                  print('Erro detalhado: ${_postStore.errorMessage}');
                }
              },
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('Detalhes do erro'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (kDebugMode)
              Text(
                'Dica: Verifique regras do Firebase e conexão de internet',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  // ✅ NOVO: Método para estado vazio (sem posts)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum post ainda',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Seja o primeiro a compartilhar algo interessante com a comunidade!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreatePostDialog,
              icon: const Icon(Icons.add),
              label: const Text('Criar primeiro post'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                minimumSize: const Size(200, 50),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _postStore.loadPosts,
              child: const Text('Atualizar feed'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NOVO: Método para conteúdo normal do feed
  Widget _buildFeedContent() {
    return RefreshIndicator(
      onRefresh: () => _postStore.loadPosts(),
      child: Column(
        children: [
          // Estatísticas rápidas
          Observer(
            builder: (_) {
              if (_postStore.totalPosts == 0) return const SizedBox();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.blue[100]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      count: _postStore.totalPosts,
                      label: 'Posts',
                      icon: Icons.article,
                      color: Colors.blue,
                    ),
                    _buildStatItem(
                      count: _postStore.totalLikes,
                      label: 'Curtidas',
                      icon: Icons.thumb_up,
                      color: Colors.red,
                    ),
                    _buildStatItem(
                      count: _postStore.sortedPosts
                          .where((post) => post.imageUrl != null)
                          .length,
                      label: 'Fotos',
                      icon: Icons.photo,
                      color: Colors.green,
                    ),
                  ],
                ),
              );
            },
          ),

          // ✅ NOVO: Indicador de loading quando carregando mais posts
          Observer(
            builder: (_) {
              if (_postStore.isLoading && _postStore.posts.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return const SizedBox();
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
                        builder: (context) => PostDetailPage(postId: post.id),
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
  }

  // ✅ NOVO: Método auxiliar para item de estatística
  Widget _buildStatItem({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showCreatePostDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(
          onPostCreated: (content, imagePath) async {
            // ✅ NOVO: Feedback visual ao criar post
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                    const SizedBox(width: 16),
                    const Text('Criando post...'),
                  ],
                ),
                duration: const Duration(seconds: 3),
              ),
            );

            try {
              if (imagePath != null) {
                await _postStore.createPostWithImage(content, imagePath);
              } else {
                await _postStore.createPost(content);
              }

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Post criado com sucesso!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Erro: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
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
                            // ✅ NOVO: Feedback visual ao editar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Salvando alterações...'),
                              ),
                            );

                            await _postStore.updatePost(
                              post.id,
                              controller.text.trim(),
                            );

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Post atualizado!'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pop(context);
                          }
                        },
                  child: _postStore.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Salvar'),
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
                          // ✅ NOVO: Feedback visual ao deletar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Excluindo post...'),
                            ),
                          );

                          await _postStore.deletePost(postId);

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Post excluído!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: _postStore.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Excluir'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}