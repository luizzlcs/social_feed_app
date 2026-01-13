import 'package:flutter/material.dart';

class FeedLoadingWidget extends StatelessWidget {
  const FeedLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando posts...'),
        ],
      ),
    );
  }
}