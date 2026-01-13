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
    // ✅ MELHORIA: Busca em todas as listas (posts, optimisticPosts)
    _post = _postStore.findPostById(widget.postId);
    
    // Se não encontrou, cria um fallback
    if (_post == null) {
      _post = _createFallbackPost();
    }
  }

  Post _createFallbackPost() {
    return Post(
      id: 'fallback',
      userId: 'user1',
      username: 'Usuário',
      content: 'Post não encontrado',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likes: 0,
      comments: 0,
      likedBy: [],
    );
  }

  // ✅ NOVO: Verifica se o usuário atual é dono do post
  bool get _isCurrentUserPost {
    return _post?.userId == _postStore.currentUserId;
  }

  // ✅ NOVO: Verifica se pode editar (é dono e não está sendo enviado)
  bool get _canEditPost {
    if (_post == null) return false;
    return _isCurrentUserPost && 
           !_postStore.shouldShowLoading(_post!.id) &&
           !_post!.syncFailed;
  }

  // ✅ NOVO: Verifica se pode excluir (é dono)
  bool get _canDeletePost {
    return _isCurrentUserPost && _post != null;
  }

  void _showEditDialog() {
    if (_post == null || !_canEditPost) return;

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
    if (!_canDeletePost) return;

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

  void _sharePost() {
    // ✅ NOVO: Opção para compartilhar posts de outros usuários
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post compartilhado!'),
      ),
    );
  }

  void _reportPost() {
    // ✅ NOVO: Opção para reportar posts inadequados
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reportar Post'),
          content: const Text('Deseja reportar este post como inadequado?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post reportado com sucesso!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Reportar'),
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
        // ✅ CORREÇÃO: Mostra ações diferentes baseado na propriedade
        actions: [
          if (_isCurrentUserPost) ...[
            // ✅ Ações para posts do usuário atual
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _canEditPost ? _showEditDialog : null,
              tooltip: 'Editar post',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _canDeletePost ? _showDeleteDialog : null,
              tooltip: 'Excluir post',
            ),
          ] else ...[
            // ✅ Ações para posts de outros usuários
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePost,
              tooltip: 'Compartilhar post',
            ),
            IconButton(
              icon: const Icon(Icons.flag),
              onPressed: _reportPost,
              tooltip: 'Reportar post',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Card do post
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ✅ Post principal com ações desabilitadas (já temos na AppBar)
                  PostCard(
                    post: _post!, 
                    showActions: false,
                    onTap: null, // Desabilita click no próprio card
                  ),

                  // ✅ Adiciona indicador de propriedade
                  if (_isCurrentUserPost)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color.fromARGB(255, 187, 222, 251)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Seu post',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

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
                        _buildInfoRow(
                          Icons.person, 
                          'Autor:', 
                          _post!.username
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.verified_user,
                          'Tipo:',
                          _isCurrentUserPost ? 'Seu post' : 'Post de outro usuário',
                        ),
                      ],
                    ),
                  ),

                  // ✅ Seção de ações (botões maiores)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Observer(
                            builder: (_) {
                              return ElevatedButton.icon(
                                onPressed: _postStore.shouldShowLoading(_post!.id)
                                    ? null
                                    : () => _postStore.likePost(_post!.id),
                                icon: Icon(
                                  _post!.likedBy.contains(_postStore.currentUserId)
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                ),
                                label: Text('Curtir (${_post!.likes})'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addComment,
                            icon: const Icon(Icons.comment),
                            label: const Text('Comentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Seção de comentários
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Comentários',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_comments.length}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

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
      likes: index % 3,
      onLike: () {
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