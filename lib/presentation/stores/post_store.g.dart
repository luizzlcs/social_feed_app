// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PostStore on _PostStoreBase, Store {
  Computed<List<Post>>? _$allPostsComputed;

  @override
  List<Post> get allPosts => (_$allPostsComputed ??= Computed<List<Post>>(
    () => super.allPosts,
    name: '_PostStoreBase.allPosts',
  )).value;
  Computed<List<Post>>? _$processingPostsComputed;

  @override
  List<Post> get processingPosts =>
      (_$processingPostsComputed ??= Computed<List<Post>>(
        () => super.processingPosts,
        name: '_PostStoreBase.processingPosts',
      )).value;
  Computed<List<Post>>? _$sortedPostsComputed;

  @override
  List<Post> get sortedPosts => (_$sortedPostsComputed ??= Computed<List<Post>>(
    () => super.sortedPosts,
    name: '_PostStoreBase.sortedPosts',
  )).value;
  Computed<int>? _$totalPostsComputed;

  @override
  int get totalPosts => (_$totalPostsComputed ??= Computed<int>(
    () => super.totalPosts,
    name: '_PostStoreBase.totalPosts',
  )).value;
  Computed<int>? _$totalLikesComputed;

  @override
  int get totalLikes => (_$totalLikesComputed ??= Computed<int>(
    () => super.totalLikes,
    name: '_PostStoreBase.totalLikes',
  )).value;
  Computed<List<Post>>? _$likedPostsComputed;

  @override
  List<Post> get likedPosts => (_$likedPostsComputed ??= Computed<List<Post>>(
    () => super.likedPosts,
    name: '_PostStoreBase.likedPosts',
  )).value;
  Computed<int>? _$userLikeCountComputed;

  @override
  int get userLikeCount => (_$userLikeCountComputed ??= Computed<int>(
    () => super.userLikeCount,
    name: '_PostStoreBase.userLikeCount',
  )).value;

  late final _$postsAtom = Atom(name: '_PostStoreBase.posts', context: context);

  @override
  ObservableList<Post> get posts {
    _$postsAtom.reportRead();
    return super.posts;
  }

  @override
  set posts(ObservableList<Post> value) {
    _$postsAtom.reportWrite(value, super.posts, () {
      super.posts = value;
    });
  }

  late final _$optimisticPostsAtom = Atom(
    name: '_PostStoreBase.optimisticPosts',
    context: context,
  );

  @override
  ObservableList<Post> get optimisticPosts {
    _$optimisticPostsAtom.reportRead();
    return super.optimisticPosts;
  }

  @override
  set optimisticPosts(ObservableList<Post> value) {
    _$optimisticPostsAtom.reportWrite(value, super.optimisticPosts, () {
      super.optimisticPosts = value;
    });
  }

  late final _$processingPostIdsAtom = Atom(
    name: '_PostStoreBase.processingPostIds',
    context: context,
  );

  @override
  ObservableSet<String> get processingPostIds {
    _$processingPostIdsAtom.reportRead();
    return super.processingPostIds;
  }

  @override
  set processingPostIds(ObservableSet<String> value) {
    _$processingPostIdsAtom.reportWrite(value, super.processingPostIds, () {
      super.processingPostIds = value;
    });
  }

  late final _$isLoadingMoreAtom = Atom(
    name: '_PostStoreBase.isLoadingMore',
    context: context,
  );

  @override
  bool get isLoadingMore {
    _$isLoadingMoreAtom.reportRead();
    return super.isLoadingMore;
  }

  @override
  set isLoadingMore(bool value) {
    _$isLoadingMoreAtom.reportWrite(value, super.isLoadingMore, () {
      super.isLoadingMore = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_PostStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_PostStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$selectedPostAtom = Atom(
    name: '_PostStoreBase.selectedPost',
    context: context,
  );

  @override
  Post? get selectedPost {
    _$selectedPostAtom.reportRead();
    return super.selectedPost;
  }

  @override
  set selectedPost(Post? value) {
    _$selectedPostAtom.reportWrite(value, super.selectedPost, () {
      super.selectedPost = value;
    });
  }

  late final _$hasMorePostsAtom = Atom(
    name: '_PostStoreBase.hasMorePosts',
    context: context,
  );

  @override
  bool get hasMorePosts {
    _$hasMorePostsAtom.reportRead();
    return super.hasMorePosts;
  }

  @override
  set hasMorePosts(bool value) {
    _$hasMorePostsAtom.reportWrite(value, super.hasMorePosts, () {
      super.hasMorePosts = value;
    });
  }

  late final _$loadPostsAsyncAction = AsyncAction(
    '_PostStoreBase.loadPosts',
    context: context,
  );

  @override
  Future<void> loadPosts() {
    return _$loadPostsAsyncAction.run(() => super.loadPosts());
  }

  late final _$loadMorePostsAsyncAction = AsyncAction(
    '_PostStoreBase.loadMorePosts',
    context: context,
  );

  @override
  Future<void> loadMorePosts() {
    return _$loadMorePostsAsyncAction.run(() => super.loadMorePosts());
  }

  late final _$refreshPostsAsyncAction = AsyncAction(
    '_PostStoreBase.refreshPosts',
    context: context,
  );

  @override
  Future<void> refreshPosts() {
    return _$refreshPostsAsyncAction.run(() => super.refreshPosts());
  }

  late final _$createPostAsyncAction = AsyncAction(
    '_PostStoreBase.createPost',
    context: context,
  );

  @override
  Future<void> createPost(String content, {String? imagePath}) {
    return _$createPostAsyncAction.run(
      () => super.createPost(content, imagePath: imagePath),
    );
  }

  late final _$likePostAsyncAction = AsyncAction(
    '_PostStoreBase.likePost',
    context: context,
  );

  @override
  Future<void> likePost(String postId) {
    return _$likePostAsyncAction.run(() => super.likePost(postId));
  }

  late final _$updatePostAsyncAction = AsyncAction(
    '_PostStoreBase.updatePost',
    context: context,
  );

  @override
  Future<void> updatePost(String postId, String newContent) {
    return _$updatePostAsyncAction.run(
      () => super.updatePost(postId, newContent),
    );
  }

  late final _$deletePostAsyncAction = AsyncAction(
    '_PostStoreBase.deletePost',
    context: context,
  );

  @override
  Future<void> deletePost(String postId) {
    return _$deletePostAsyncAction.run(() => super.deletePost(postId));
  }

  late final _$addCommentAsyncAction = AsyncAction(
    '_PostStoreBase.addComment',
    context: context,
  );

  @override
  Future<void> addComment(String postId) {
    return _$addCommentAsyncAction.run(() => super.addComment(postId));
  }

  late final _$loadLikedPostsAsyncAction = AsyncAction(
    '_PostStoreBase.loadLikedPosts',
    context: context,
  );

  @override
  Future<List<Post>> loadLikedPosts() {
    return _$loadLikedPostsAsyncAction.run(() => super.loadLikedPosts());
  }

  late final _$_PostStoreBaseActionController = ActionController(
    name: '_PostStoreBase',
    context: context,
  );

  @override
  void setCurrentUserId(String userId) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.setCurrentUserId',
    );
    try {
      return super.setCurrentUserId(userId);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectPost(Post post) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.selectPost',
    );
    try {
      return super.selectPost(post);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelection() {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.clearSelection',
    );
    try {
      return super.clearSelection();
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _cleanupStaleProcessing() {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase._cleanupStaleProcessing',
    );
    try {
      return super._cleanupStaleProcessing();
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateOptimisticPostWithRealData(String postId, Post realPost) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase._updateOptimisticPostWithRealData',
    );
    try {
      return super._updateOptimisticPostWithRealData(postId, realPost);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _markOptimisticPostAsFailed(String postId, String error) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase._markOptimisticPostAsFailed',
    );
    try {
      return super._markOptimisticPostAsFailed(postId, error);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _removeSyncedOptimisticPosts(List<Post> realPosts) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase._removeSyncedOptimisticPosts',
    );
    try {
      return super._removeSyncedOptimisticPosts(realPosts);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
posts: ${posts},
optimisticPosts: ${optimisticPosts},
processingPostIds: ${processingPostIds},
isLoadingMore: ${isLoadingMore},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
selectedPost: ${selectedPost},
hasMorePosts: ${hasMorePosts},
allPosts: ${allPosts},
processingPosts: ${processingPosts},
sortedPosts: ${sortedPosts},
totalPosts: ${totalPosts},
totalLikes: ${totalLikes},
likedPosts: ${likedPosts},
userLikeCount: ${userLikeCount}
    ''';
  }
}
