import 'package:flutter/material.dart';

class PostHeaderActions extends StatelessWidget {
  final bool isCurrentUserPost;
  final bool canEditPost;
  final bool canDeletePost;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const PostHeaderActions({
    super.key,
    required this.isCurrentUserPost,
    required this.canEditPost,
    required this.canDeletePost,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    if (isCurrentUserPost) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: canEditPost ? onEdit : null,
            tooltip: 'Editar post',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: canDeletePost ? onDelete : null,
            tooltip: 'Excluir post',
          ),
        ],
      );
    } else {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: onShare,
            tooltip: 'Compartilhar post',
          ),
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: onReport,
            tooltip: 'Reportar post',
          ),
        ],
      );
    }
  }
}