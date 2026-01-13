import 'package:flutter/material.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/widgets/universal_image.dart';

class PostContent extends StatelessWidget {
  final Post post;
  final bool isActuallyOptimistic;

  const PostContent({
    super.key,
    required this.post,
    required this.isActuallyOptimistic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.content,
          style: TextStyle(
            fontSize: 15,
            color: isActuallyOptimistic ? Colors.grey[700] : null,
          ),
        ),
        if (post.imageUrl != null) ...[
          const SizedBox(height: 12),
          _buildImage(post.imageUrl!),
        ],
      ],
    );
  }

  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: UniversalImage.fromPathOrUrl(
        pathOrUrl: imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}