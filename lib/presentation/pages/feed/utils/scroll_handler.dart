import 'package:flutter/material.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';

class ScrollHandler {
  final ScrollController controller;
  final PostStore postStore;

  ScrollHandler(this.postStore) : controller = ScrollController() {
    controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      postStore.loadMorePosts();
    }
  }

  void dispose() {
    controller.dispose();
  }
}