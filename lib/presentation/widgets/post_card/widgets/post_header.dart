import 'package:flutter/material.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/widgets/post_card/widgets/post_status_indicator.dart';
import 'package:social_feed_app/presentation/widgets/post_card/utils/post_card_helper.dart';

class PostHeader extends StatelessWidget {
  final Post post;
  final bool isCurrentUserPost;
  final bool isActuallyOptimistic;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostHeader({
    super.key,
    required this.post,
    required this.isCurrentUserPost,
    required this.isActuallyOptimistic,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final helper = PostCardHelper();
    final displayUsername = helper.getDisplayUsername(post, isCurrentUserPost);
    final avatarInitial = helper.getAvatarInitial(displayUsername);
    final avatarColor = helper.getAvatarColor(
      context,
      post,
      isActuallyOptimistic,
      isCurrentUserPost,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(context, avatarInitial, avatarColor, isActuallyOptimistic, isCurrentUserPost),
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
                    style: _getUsernameStyle(context, isActuallyOptimistic, isCurrentUserPost),
                  ),
                  PostStatusIndicator(post: post),
                ],
              ),
              Text(
                helper.formatDateTime(post.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (isCurrentUserPost && !isActuallyOptimistic && (onEdit != null || onDelete != null))
          _buildMenuButton(onEdit, onDelete),
      ],
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    String initial,
    Color? color,
    bool isOptimistic,
    bool isCurrentUser,
  ) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Text(
            initial,
            style: TextStyle(
              color: isOptimistic ? Colors.blue[800] : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (isOptimistic)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sync, size: 10, color: Colors.white),
            ),
          ),
        if (isCurrentUser && !isOptimistic)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Icon(Icons.person, size: 8, color: Colors.white),
            ),
          ),
      ],
    );
  }

  TextStyle? _getUsernameStyle(BuildContext context, bool isOptimistic, bool isCurrentUser) {
    if (isOptimistic) {
      return TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.blue[800],
      );
    }
    
    if (isCurrentUser) {
      return TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Theme.of(context).primaryColor,
      );
    }
    
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
  }

  Widget _buildMenuButton(VoidCallback? onEdit, VoidCallback? onDelete) {
    return PopupMenuButton<String>(
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
    );
  }
}