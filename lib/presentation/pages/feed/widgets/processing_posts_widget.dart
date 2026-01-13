import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';

class ProcessingPostsWidget extends StatelessWidget {
  final PostStore postStore;

  const ProcessingPostsWidget({super.key, required this.postStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (postStore.processingPosts.isEmpty) return const SizedBox();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Sincronizando (${postStore.processingPosts.length})',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}