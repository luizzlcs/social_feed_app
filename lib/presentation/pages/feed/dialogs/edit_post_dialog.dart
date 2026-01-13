import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';

class EditPostDialog extends StatefulWidget {
  final Post post;
  final PostStore postStore;
  final VoidCallback onPostUpdated;

  const EditPostDialog({
    super.key,
    required this.post,
    required this.postStore,
    required this.onPostUpdated,
  });

  @override
  State<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<EditPostDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    if (_controller.text.trim().isNotEmpty) {
      await widget.postStore.updatePost(
        widget.post.id,
        _controller.text.trim(),
      );
      widget.onPostUpdated();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Post'),
      content: TextField(
        controller: _controller,
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
              onPressed:
                  widget.postStore.isLoading || widget.postStore.isLoadingMore
                      ? null
                      : _savePost,
              child: const Text('Salvar'),
            );
          },
        ),
      ],
    );
  }
}