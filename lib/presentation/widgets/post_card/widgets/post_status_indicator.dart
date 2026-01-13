import 'package:flutter/material.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';

class PostStatusIndicator extends StatelessWidget {
  final Post post;

  const PostStatusIndicator({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final postStore = getIt<PostStore>();
    final shouldShowLoading = postStore.shouldShowLoading(post.id);

    if (shouldShowLoading && post.isOptimistic) {
      return _buildSendingIndicator();
    }

    if (shouldShowLoading && !post.isOptimistic) {
      return const SizedBox();
    }

    if (post.syncFailed) {
      return _buildFailedIndicator();
    }

    return const SizedBox();
  }

  Widget _buildSendingIndicator() {
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

  Widget _buildFailedIndicator() {
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
}