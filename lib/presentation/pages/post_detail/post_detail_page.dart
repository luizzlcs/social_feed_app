import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';
import 'package:social_feed_app/presentation/widgets/post_card.dart';
import 'package:intl/intl.dart';
import 'package:social_feed_app/presentation/widgets/comment_item.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late final PostStore _postStore;
  Post? _post;

  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [
    'Ótimo post! Concordo plenamente.',
    'Muito interessante, obrigado por compartilhar!',
    'Tem mais informações sobre isso?',
    'Isso me lembrou de um projeto que fiz recentemente.',
    'Excelente conteúdo, continue postando!',
  ];

  @override
  void initState() {
    super.initState();
    _postStore = getIt<PostStore>();
    _loadPost();
  }

  void _loadPost() {
    // Busca o post pelo ID
    _post = _postStore.posts.firstWhere(
      (post) => post.id == widget.postId,
      orElse: () => _postStore.posts.isNotEmpty
          ? _postStore.posts.first
          : _createFallbackPost(),
    );
  }

  Post _createFallbackPost() {
    return Post(
      id: 'fallback',
      userId: 'user1',
      username: 'Usuário',
      content: 'Post não encontrado',
      createdAt: DateTime.now(),
    );
  }

  void _showEditDialog() {
    if (_post == null) return;

    final TextEditingController controller = TextEditingController(
      text: _post!.content,
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
                              _post!.id,
                              controller.text.trim(),
                            );
                            setState(() {
                              _post = _post!.copyWith(
                                content: controller.text.trim(),
                              );
                            });
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post atualizado com sucesso!'),
                              ),
                            );
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

  void _showDeleteDialog() {
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
                          await _postStore.deletePost(_post!.id);
                          Navigator.pop(context);
                          Navigator.pop(context); // Volta para o feed

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post excluído com sucesso!'),
                            ),
                          );
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

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.insert(0, _commentController.text.trim());
        _postStore.addComment(_post!.id);
        _commentController.clear();
      });

      // Fecha o teclado
      FocusScope.of(context).unfocus();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final format = DateFormat('dd/MM/yyyy HH:mm');
    return format.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Post'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Card do post
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Post principal
                  PostCard(post: _post!, showActions: false),

                  // Informações detalhadas
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informações do Post',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Criado em:',
                          _formatDateTime(_post!.createdAt),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.thumb_up,
                          'Curtidas:',
                          '${_post!.likes}',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.comment,
                          'Comentários:',
                          '${_comments.length}',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.person, 'Autor:', _post!.username),
                      ],
                    ),
                  ),

                  // Seção de comentários
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comentários',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (_comments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'Nenhum comentário ainda. Seja o primeiro!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ..._comments.asMap().entries.map((entry) {
                            final index = entry.key;
                            final comment = entry.value;
                            return _buildCommentItem(comment, index);
                          }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Input para novo comentário
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Adicione um comentário...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _addComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(String comment, int index) {
    final times = ['Há 2 min', 'Há 15 min', 'Há 1 hora', 'Há 3 horas', 'Ontem'];

    final users = [
      'João Silva',
      'Maria Santos',
      'Pedro Costa',
      'Ana Oliveira',
      'Carlos Mendes',
    ];

    return CommentItem(
      username: users[index % users.length],
      comment: comment,
      timeAgo: times[index % times.length],
      likes: index % 3, // Alguns comentários com curtidas
      onLike: () {
        // Implementar curtida no comentário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Curtiu comentário de ${users[index % users.length]}',
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
