import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/widgets/universal_image.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart'; // ✅ Importar AuthStore

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inHours < 1) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Há ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  Widget _buildStatusIndicator() {
    final postStore = getIt<PostStore>();
    final shouldShowLoading = postStore.shouldShowLoading(post.id);

    if (shouldShowLoading && post.isOptimistic) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Enviando...',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (shouldShowLoading && !post.isOptimistic) {
      return const SizedBox();
    }

    if (post.syncFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 12, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              'Falhou',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final postStore = getIt<PostStore>();
        final authStore = getIt<AuthStore>();
        final isActuallyOptimistic = postStore.shouldShowLoading(post.id);
        
        // ✅ SOLUÇÃO 1: Usar userId para comparar (mais comum)
        // Assumindo que authStore.currentUserId retorna o ID do usuário logado
        final isCurrentUserPost = post.userId == authStore.userId;
        
        // ✅ SOLUÇÃO 2: Se você tiver acesso ao email no authStore
        // Você pode comparar se o username do post é igual ao nome do usuário logado
        // Mas isso é menos confiável, pois nomes podem se repetir
        
        final isInteractive = !isActuallyOptimistic;

        // ✅ Determina o nome de usuário correto
        String getDisplayUsername() {
          // Verifica se é o usuário atual (opção mais segura)
          if (isCurrentUserPost) {
            return 'Você'; // Só mostra "Você" para posts do usuário logado
          } else if (post.username.isNotEmpty) {
            return post.username; // Username do post
          } else {
            return 'Usuário'; // Fallback
          }
        }
        
        final displayUsername = getDisplayUsername();

        // ✅ Obtém a primeira letra do username para o avatar
        String getAvatarInitial() {
          if (displayUsername.isNotEmpty) {
            return displayUsername[0].toUpperCase();
          }
          return '?';
        }

        // ✅ Função para obter a cor do avatar baseado no usuário
        Color? getAvatarColor(BuildContext context) {
          if (isActuallyOptimistic) {
            return Colors.blue[100];
          } else if (isCurrentUserPost) {
            return Theme.of(context).primaryColor; // Cor primária para "Você"
          } else {
            // Gera uma cor consistente baseada no userId ou username
            final userIdOrUsername = post.userId + post.username;
            if (userIdOrUsername.isEmpty) return Colors.grey[400];
            
            // Hash simples para gerar cor
            final hash = userIdOrUsername.hashCode;
            final colors = [
              Colors.red[400],
              Colors.blue[400],
              Colors.green[400],
              Colors.orange[400],
              Colors.purple[400],
              Colors.teal[400],
              Colors.pink[400],
              Colors.cyan[400],
              Colors.indigo[400],
              Colors.amber[400],
            ];
            return colors[hash.abs() % colors.length];
          }
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: isActuallyOptimistic ? 1 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: post.syncFailed
                ? BorderSide(color: Colors.red.withOpacity(0.3))
                : isActuallyOptimistic
                    ? BorderSide(color: Colors.blue.withOpacity(0.3))
                    : BorderSide.none,
          ),
          child: Opacity(
            opacity: isActuallyOptimistic ? 0.9 : 1.0,
            child: InkWell(
              onTap: isActuallyOptimistic ? null : onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: getAvatarColor(context),
                              child: Text(
                                getAvatarInitial(),
                                style: TextStyle(
                                  color: isActuallyOptimistic
                                      ? Colors.blue[800]
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isActuallyOptimistic)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.sync,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            // ✅ BADGE para posts do usuário atual
                            if (isCurrentUserPost && !isActuallyOptimistic)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    displayUsername,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isActuallyOptimistic
                                          ? Colors.blue[800]
                                          : isCurrentUserPost
                                              ? Theme.of(context).primaryColor
                                              : null,
                                    ),
                                  ),
                                  _buildStatusIndicator(),
                                ],
                              ),
                              Text(
                                _formatDateTime(post.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrentUserPost &&
                            !isActuallyOptimistic &&
                            (onEdit != null || onDelete != null))
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'edit' && onEdit != null) {
                                onEdit!();
                              } else if (value == 'delete' &&
                                  onDelete != null) {
                                onDelete!();
                              }
                            },
                            itemBuilder: (context) => [
                              if (onEdit != null)
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                              if (onDelete != null)
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Excluir',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Conteúdo do post
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: isActuallyOptimistic ? Colors.grey[700] : null,
                      ),
                    ),

                    // Imagem do post (se houver)
                    if (post.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: UniversalImage.fromPathOrUrl(
                          pathOrUrl: post.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],

                    if (showActions && !isActuallyOptimistic) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Botão de curtir
                          InkWell(
                            onTap: isActuallyOptimistic ? null : onLike,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    size: 18,
                                    color: post.likedBy.contains(
                                          authStore.userId, // ✅ Usar authStore
                                        )
                                        ? Colors.red
                                        : Colors.blue[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${post.likes}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Botão de comentar
                          InkWell(
                            onTap: isActuallyOptimistic ? null : onComment,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.comment,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${post.comments}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (post.syncFailed && post.syncError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Falha ao sincronizar: ${post.syncError}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            if (post.isOptimistic)
                              TextButton(
                                onPressed: () {
                                  // Lógica para tentar novamente
                                },
                                child: const Text(
                                  'Tentar novamente',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}