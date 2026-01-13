import 'package:flutter/material.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/pages/post_detail/utils/post_detail_helper.dart';

class PostInfoCard extends StatelessWidget {
  final Post post;
  final bool isCurrentUserPost;

  const PostInfoCard({
    super.key,
    required this.post,
    required this.isCurrentUserPost,
  });

  @override
  Widget build(BuildContext context) {
    final helper = PostDetailHelper();

    return Container(
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
            helper.formatDateTime(post.createdAt),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.thumb_up,
            'Curtidas:',
            '${post.likes}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.comment,
            'Comentários:',
            '${post.comments}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.person,
            'Autor:',
            post.username,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.verified_user,
            'Tipo:',
            isCurrentUserPost ? 'Seu post' : 'Post de outro usuário',
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
}