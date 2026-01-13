import 'package:flutter/material.dart';

class FeedEmptyState extends StatelessWidget {
  final VoidCallback onCreatePost;

  const FeedEmptyState({
    super.key,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.feed, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nenhum post ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Seja o primeiro a compartilhar algo!',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onCreatePost,
            child: const Text('Criar primeiro post'),
          ),
        ],
      ),
    );
  }
}