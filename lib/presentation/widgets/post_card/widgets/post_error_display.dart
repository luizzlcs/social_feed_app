import 'package:flutter/material.dart';
import 'package:social_feed_app/domain/entities/post.dart';

class PostErrorDisplay extends StatelessWidget {
  final Post post;

  const PostErrorDisplay({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Falha ao sincronizar: ${post.syncError}',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
          if (post.isOptimistic)
            TextButton(
              onPressed: () {
                // TODO: Implementar lógica para tentar novamente
              },
              child: const Text('Tentar novamente', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}