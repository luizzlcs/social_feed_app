import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';

class FeedStatsWidget extends StatelessWidget {
  final PostStore postStore;

  const FeedStatsWidget({super.key, required this.postStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (postStore.totalPosts == 0) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                value: '${postStore.totalPosts}',
                label: 'Posts',
                color: Colors.blue,
              ),
              _buildStatItem(
                value: '${postStore.totalLikes}',
                label: 'Curtidas',
                color: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}