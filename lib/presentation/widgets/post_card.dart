import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_feed_app/core/dependency_injection.dart'; // ✅ Importar GetIt
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/widgets/universal_image.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart'; // ✅ Importar PostStore

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

  // ✅ MODIFICADO: Widget para indicador de status (com GetIt)
  Widget _buildStatusIndicator() {
    // Acessa o PostStore diretamente do GetIt
    final postStore = getIt<PostStore>();
    final shouldShowLoading = postStore.shouldShowLoading(post.id);
    
    // Se está processando, mostra "Enviando..."
    if (shouldShowLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1 * 255.round()),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3 * 255.round())),
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
    
    // Se falhou na sincronização
    if (post.syncFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1 * 255.round()),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3 * 255.round())),
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
    
    // Se foi sincronizado com sucesso, mas ainda tem isOptimistic=true
    // (isso acontece quando recarrega o app antes do post ser atualizado)
    if (post.isOptimistic && !shouldShowLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1 * 255.round()),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3 * 255.round())),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 12, color: Color.fromARGB(255, 113, 192, 103)),
            const SizedBox(width: 4),
            Text(
              'Enviado',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox();
  }

  // ✅ NOVO: Método para verificar se o post é realmente otimista (com GetIt)
  bool _isActuallyOptimistic() {
    final postStore = getIt<PostStore>();
    // Um post é "realmente" otimista se está sendo processado
    return postStore.shouldShowLoading(post.id);
  }

  // ✅ Verifica se pode interagir com o post
  bool _isPostInteractive() {
    return !_isActuallyOptimistic();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Usar StatefulBuilder para permitir rebuild quando o estado mudar
    // ou usar um widget que reage às mudanças do MobX
    return StatefulBuilder(
      builder: (context, setState) {
        // Acessar o PostStore do GetIt
        final postStore = getIt<PostStore>();
        
        // ✅ Usar reaction do MobX para observar mudanças
        // ou usar um observer widget se estiver usando mobx_widgets
        // Por enquanto, usaremos uma abordagem mais simples
        
        final isActuallyOptimistic = postStore.shouldShowLoading(post.id);
        final isInteractive = !isActuallyOptimistic;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: isActuallyOptimistic ? 1 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: post.syncFailed 
                ? BorderSide(color: Colors.red.withValues(alpha: 0.3 * 255.round()))
                : isActuallyOptimistic
                    ? BorderSide(color: Colors.blue.withValues(alpha: 0.3 * 255.round()))
                    : BorderSide.none,
          ),
          child: Opacity(
            opacity: isActuallyOptimistic ? 0.9 : 1.0,
            child: InkWell(
              onTap: isInteractive ? onTap : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho do post
                    Row(
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
                              Row(
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
                                  const SizedBox(width: 8),
                                  // ✅ Usar o método modificado
                                  _buildStatusIndicator(),
                                ],
                              ),
                              // ✅ MOSTRAR TEMPO MESMO SE FOR OPTIMISTA MAS JÁ SINCRONIZADO
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
                        if (isInteractive && (onEdit != null || onDelete != null))
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'edit' && onEdit != null) {
                                onEdit!();
                              } else if (value == 'delete' && onDelete != null) {
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
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Excluir', style: TextStyle(color: Colors.red)),
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
                    
                    // Ações do post (curtir, comentar)
                    if (showActions && isInteractive) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Botão de curtir
                          InkWell(
                            onTap: onLike,
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
                                    color: Colors.blue[700],
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
                            onTap: onComment,
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
                    
                    // ✅ MODIFICADO: Mensagem de erro se falhou
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
                            const Icon(Icons.warning, size: 16, color: Colors.red),
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
                            if (post.isOptimistic) // ✅ Só mostra se ainda for otimista
                              TextButton(
                                onPressed: () {
                                  // ✅ Poderia adicionar lógica para tentar novamente
                                  // postStore.retryPost(post.id);
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