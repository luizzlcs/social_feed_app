import 'package:flutter/material.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';

class PostActions extends StatelessWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const PostActions({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final authStore = getIt<AuthStore>();
    final isLiked = post.likedBy.contains(authStore.userId);

    return Row(
      children: [
        _buildLikeButton(isLiked, onLike),
        const SizedBox(width: 12),
        _buildCommentButton(onComment),
      ],
    );
  }

  Widget _buildLikeButton(bool isLiked, VoidCallback? onLike) {
    return InkWell(
      onTap: onLike,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.thumb_up,
              size: 18,
              color: isLiked ? Colors.red : Colors.blue[700],
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
    );
  }

  Widget _buildCommentButton(VoidCallback? onComment) {
    return InkWell(
      onTap: onComment,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.comment, size: 18, color: Colors.green),
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
    );
  }
}