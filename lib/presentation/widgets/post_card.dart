import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/widgets/universal_image.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';

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

    // ✅ CORREÇÃO: Mostra "Enviando..." apenas para NOVOS posts otimistas
    // Não mostra para edições de posts existentes
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

    // ✅ Para posts que estão sendo processados mas NÃO são otimistas (edições)
    // Não mostra nada - atualização silenciosa
    if (shouldShowLoading && !post.isOptimistic) {
      // ✅ Edições em andamento - sem feedback visual
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

    // ✅ REMOVIDO: Não mostra mais "Enviado" para posts otimistas já sincronizados
    // Isso causava confusão e não é necessário
    
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final postStore = getIt<PostStore>();
        final isActuallyOptimistic = postStore.shouldShowLoading(post.id);
        
        // ✅ CORREÇÃO: Verificar se o usuário atual é o dono do post
        final isCurrentUserPost = post.userId == postStore.currentUserId;

        // ✅ CORREÇÃO: Posts são interativos a menos que estejam sendo enviados
        // Posts com syncFailed ainda podem ser clicáveis (para ver detalhes)
        final isInteractive = !isActuallyOptimistic;

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
              // ✅ CORREÇÃO: Permitir tap em todos os posts, exceto os que estão sendo enviados
              // Posts com syncFailed podem ser clicados (para ver detalhes do erro)
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
                              backgroundColor: isActuallyOptimistic
                                  ? Colors.blue[100]
                                  : Theme.of(context).primaryColor,
                              child: Text(
                                post.username[0].toUpperCase(),
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
                                    post.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isActuallyOptimistic
                                          ? Colors.blue[800]
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
                        // ✅ CORREÇÃO CRÍTICA: Mostrar menu se for dono do post
                        // E não estiver sendo enviado (isActuallyOptimistic)
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

                    // ✅ CORREÇÃO: Ações disponíveis se não estiver sendo enviado
                    if (showActions && !isActuallyOptimistic) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Botão de curtir
                          InkWell(
                            // ✅ CORREÇÃO: Curtir disponível sempre, exceto durante envio
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
                                  // ✅ BÔNUS: Mostrar cor diferente se já curtiu
                                  Icon(
                                    Icons.thumb_up,
                                    size: 18,
                                    color: post.likedBy.contains(
                                          postStore.currentUserId,
                                        )
                                        ? Colors.red // Já curtiu
                                        : Colors.blue[700], // Não curtiu ainda
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
                            // ✅ CORREÇÃO: Comentar disponível sempre, exceto durante envio
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

                    // Mensagem de erro se falhou
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