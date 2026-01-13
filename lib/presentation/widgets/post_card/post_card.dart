import 'package:flutter/material.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/widgets/post_card/widgets/post_header.dart';
import 'package:social_feed_app/presentation/widgets/post_card/widgets/post_content.dart';
import 'package:social_feed_app/presentation/widgets/post_card/widgets/post_actions.dart';
import 'package:social_feed_app/presentation/widgets/post_card/widgets/post_error_display.dart';
import 'package:social_feed_app/presentation/widgets/post_card/utils/post_card_helper.dart';

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

  @override
  Widget build(BuildContext context) {
    final helper = PostCardHelper();
    final isActuallyOptimistic = helper.isPostOptimistic(post.id);
    final isCurrentUserPost = helper.isCurrentUserPost(post);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isActuallyOptimistic ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: helper.getCardBorder(post, isActuallyOptimistic),
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
                PostHeader(
                  post: post,
                  isCurrentUserPost: isCurrentUserPost,
                  isActuallyOptimistic: isActuallyOptimistic,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
                const SizedBox(height: 16),
                PostContent(post: post, isActuallyOptimistic: isActuallyOptimistic),
                const SizedBox(height: 12),
                if (showActions && !isActuallyOptimistic)
                  PostActions(
                    post: post,
                    onLike: onLike,
                    onComment: onComment,
                  ),
                if (post.syncFailed && post.syncError != null)
                  PostErrorDisplay(post: post),
              ],
            ),
          ),
        ),
      ),
    );
  }
}