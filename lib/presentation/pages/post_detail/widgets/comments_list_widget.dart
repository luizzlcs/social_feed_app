import 'package:flutter/material.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/widgets/comment_item.dart';

class CommentsListWidget extends StatefulWidget {
  final Post post;

  const CommentsListWidget({super.key, required this.post});

  @override
  State<CommentsListWidget> createState() => _CommentsListWidgetState();
}

class _CommentsListWidgetState extends State<CommentsListWidget> {
  final List<String> _comments = [
    'Ótimo post! Concordo plenamente.',
    'Muito interessante, obrigado por compartilhar!',
    'Tem mais informações sobre isso?',
    'Isso me lembrou de um projeto que fiz recentemente.',
    'Excelente conteúdo, continue postando!',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Comentários',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_comments.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_comments.isEmpty)
            _buildEmptyComments()
          else
            _buildCommentsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'Nenhum comentário ainda. Seja o primeiro!',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    final times = ['Há 2 min', 'Há 15 min', 'Há 1 hora', 'Há 3 horas', 'Ontem'];
    final users = [
      'João Silva',
      'Maria Santos',
      'Pedro Costa',
      'Ana Oliveira',
      'Carlos Mendes',
    ];

    return Column(
      children: _comments.asMap().entries.map((entry) {
        final index = entry.key;
        final comment = entry.value;
        return CommentItem(
          username: users[index % users.length],
          comment: comment,
          timeAgo: times[index % times.length],
          likes: index % 3,
          onLike: () => _onCommentLike(context, users[index % users.length]),
        );
      }).toList(),
    );
  }

  void _onCommentLike(BuildContext context, String username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Curtiu comentário de $username'),
      ),
    );
  }
}