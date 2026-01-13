import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/presentation/stores/post_store/post_store.dart';

class DeletePostDialog extends StatelessWidget {
  final String postId;
  final PostStore postStore;
  final VoidCallback onPostDeleted;

  const DeletePostDialog({
    super.key,
    required this.postId,
    required this.postStore,
    required this.onPostDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir Post'),
      content: const Text('Tem certeza que deseja excluir este post?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        Observer(
          builder: (_) {
            return ElevatedButton(
              onPressed: postStore.isLoading || postStore.isLoadingMore
                  ? null
                  : () => _deletePost(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _deletePost(BuildContext context) async {
    await postStore.deletePost(postId);
    onPostDeleted();
    Navigator.pop(context);
  }
}