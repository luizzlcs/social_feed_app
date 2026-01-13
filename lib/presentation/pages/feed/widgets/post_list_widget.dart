import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';
import 'package:social_feed_app/presentation/widgets/post_card.dart';

class PostListWidget extends StatelessWidget {
  final ScrollController scrollController;
  final PostStore postStore;
  final Function(Post) onPostTap;
  final Function(String) onPostLike;
  final Function(String) onPostComment;
  final Function(Post) onPostEdit;
  final Function(String) onPostDelete;

  const PostListWidget({
    super.key,
    required this.scrollController,
    required this.postStore,
    required this.onPostTap,
    required this.onPostLike,
    required this.onPostComment,
    required this.onPostEdit,
    required this.onPostDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: _calculateItemCount(),
      itemBuilder: (context, index) => _buildListItem(index),
    );
  }

  int _calculateItemCount() {
    return postStore.sortedPosts.length +
        (postStore.hasMorePosts || postStore.isLoadingMore ? 1 : 0);
  }

  Widget _buildListItem(int index) {
    if (index >= postStore.sortedPosts.length) {
      return _buildLoadMoreItem();
    }

    final post = postStore.sortedPosts[index];
    return _buildPostCard(post);
  }

  Widget _buildLoadMoreItem() {
    return Observer(
      builder: (_) {
        if (postStore.isLoadingMore) {
          return const _LoadingIndicator();
        }

        if (postStore.hasMorePosts) {
          return _LoadMoreButton(onPressed: postStore.loadMorePosts);
        }

        return Container();
      },
    );
  }

  Widget _buildPostCard(Post post) {
    return PostCard(
      post: post,
      onTap: () => onPostTap(post),
      onLike: () => onPostLike(post.id),
      onComment: () => onPostComment(post.id),
      onEdit: post.isOptimistic ? null : () => onPostEdit(post),
      onDelete: post.isOptimistic ? null : () => onPostDelete(post.id),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoadMoreButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          child: const Text('Carregar mais posts'),
        ),
      ),
    );
  }
}