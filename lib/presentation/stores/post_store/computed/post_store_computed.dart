// Todas as computed properties

import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';

class PostStoreComputed {
  final ObservableList<Post> posts;
  final ObservableList<Post> optimisticPosts;
  final String? currentUserId;

  PostStoreComputed({
    required this.posts,
    required this.optimisticPosts,
    required this.currentUserId,
  });

  @computed
  List<Post> get allPosts {
    final combined = <Post>[...posts, ...optimisticPosts];
    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final seenIds = <String>{};
    return combined.where((post) => seenIds.add(post.id)).toList();
  }

  @computed
  List<Post> get processingPosts => optimisticPosts
      .where((post) => post.isOptimistic)
      .toList();

  @computed
  List<Post> get sortedPosts => allPosts;

  @computed
  int get totalPosts => allPosts.length;

  @computed
  int get totalLikes => allPosts.fold(0, (sum, post) => sum + post.likes);

  @computed
  List<Post> get likedPosts => allPosts
      .where((post) => post.likedBy.contains(currentUserId))
      .toList();

  @computed
  int get userLikeCount => allPosts
      .where((post) => post.likedBy.contains(currentUserId))
      .length;
}