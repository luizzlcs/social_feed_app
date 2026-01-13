import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store/post_store.dart';

class PostDetailHelper {
  String formatDateTime(DateTime dateTime) {
    final format = DateFormat('dd/MM/yyyy HH:mm');
    return format.format(dateTime);
  }

  Post createFallbackPost() {
    return Post(
      id: 'fallback',
      userId: 'user1',
      username: 'Usuário',
      content: 'Post não encontrado',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likes: 0,
      comments: 0,
      likedBy: [],
    );
  }

  void showEditDialog({
    required BuildContext context,
    required Post post,
    required PostStore postStore,
    required Function(String) onPostUpdated,
  }) {
    final controller = TextEditingController(text: post.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Post'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Edite seu post...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            Observer(
              builder: (_) {
                return ElevatedButton(
                  onPressed: postStore.isLoading
                      ? null
                      : () async {
                          if (controller.text.trim().isNotEmpty) {
                            await postStore.updatePost(
                              post.id,
                              controller.text.trim(),
                            );
                            onPostUpdated(controller.text.trim());
                            Navigator.pop(context);
                            showSuccessSnackBar(
                              context,
                              'Post atualizado com sucesso!',
                            );
                          }
                        },
                  child: const Text('Salvar'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog({
    required BuildContext context,
    required String postId,
    required PostStore postStore,
    required VoidCallback onPostDeleted,
  }) {
    showDialog(
      context: context,
      builder: (context) {
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
                  onPressed: postStore.isLoading
                      ? null
                      : () async {
                          await postStore.deletePost(postId);
                          onPostDeleted();
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Excluir'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void showShareDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post compartilhado!'),
      ),
    );
  }

  void showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reportar Post'),
          content: const Text('Deseja reportar este post como inadequado?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showSuccessSnackBar(
                  context,
                  'Post reportado com sucesso!',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Reportar'),
            ),
          ],
        );
      },
    );
  }

  /// Adiciona um comentário
  void addComment(
    String comment,
    String postId,
    PostStore postStore,
    VoidCallback onSuccess,
  ) {
    postStore.addComment(postId);
    onSuccess();
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}