import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/post_store.dart';

class PostActionsButtons extends StatelessWidget {
  final Post post;
  final PostStore postStore;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const PostActionsButtons({
    super.key,
    required this.post,
    required this.postStore,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Observer(
              builder: (_) {
                return ElevatedButton.icon(
                  onPressed: postStore.shouldShowLoading(post.id)
                      ? null
                      : onLike,
                  icon: Icon(
                    post.likedBy.contains(postStore.currentUserId)
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                  ),
                  label: Text('Curtir (${post.likes})'),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onComment,
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
    );
  }
}