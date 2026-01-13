import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';
import 'package:social_feed_app/presentation/stores/post_store/post_store.dart';

class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PostStore postStore;
  final AuthStore authStore;
  final VoidCallback onCreatePost;

  const FeedAppBar({
    super.key,
    required this.postStore,
    required this.authStore,
    required this.onCreatePost,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Observer(
        builder: (_) {
          return Row(
            children: [
              const Text('Feed'),
              const SizedBox(width: 8),
              if (postStore.totalPosts > 0)
                Chip(
                  label: Text('${postStore.totalPosts}'),
                  backgroundColor: Colors.white,
                ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onCreatePost,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: authStore.logout,
        ),
      ],
    );
  }
}