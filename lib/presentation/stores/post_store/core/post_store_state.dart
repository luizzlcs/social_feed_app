// Estado observável

import 'package:mobx/mobx.dart';
import 'package:social_feed_app/domain/entities/post.dart';

part 'post_store_state.g.dart';

class PostStoreState = _PostStoreStateBase with _$PostStoreState;

abstract class _PostStoreStateBase with Store {
  @observable
  ObservableList<Post> posts = ObservableList<Post>();

  @observable
  ObservableList<Post> optimisticPosts = ObservableList<Post>();

  @observable
  ObservableSet<String> processingPostIds = ObservableSet<String>();

  @observable
  bool isLoadingMore = false;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  Post? selectedPost;

  @observable
  bool hasMorePosts = true;

  @observable
  String? currentUserId;

  // Mapas para controle interno (não observáveis)
  final Map<String, DateTime> processingStartTimes = {};
  final Map<String, DateTime> lastLikeAttemptTimes = {};
}