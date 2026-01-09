// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PostStore on _PostStoreBase, Store {
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

  late final _$loadPostsAsyncAction = AsyncAction(
    '_PostStoreBase.loadPosts',
    context: context,
  );

  @override
  Future<void> loadPosts() {
    return _$loadPostsAsyncAction.run(() => super.loadPosts());
  }

  late final _$createPostAsyncAction = AsyncAction(
    '_PostStoreBase.createPost',
    context: context,
  );

  @override
  Future<void> createPost(String content, {String? imageUrl}) {
    return _$createPostAsyncAction.run(
      () => super.createPost(content, imageUrl: imageUrl),
    );
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

  late final _$createPostWithImageAsyncAction = AsyncAction(
    '_PostStoreBase.createPostWithImage',
    context: context,
  );

  @override
  Future<void> createPostWithImage(String content, String? imagePath) {
    return _$createPostWithImageAsyncAction.run(
      () => super.createPostWithImage(content, imagePath),
    );
  }

  late final _$_PostStoreBaseActionController = ActionController(
    name: '_PostStoreBase',
    context: context,
  );

  @override
  void likePost(String postId) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.likePost',
    );
    try {
      return super.likePost(postId);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addComment(String postId) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.addComment',
    );
    try {
      return super.addComment(postId);
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
  String toString() {
    return '''
posts: ${posts},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
selectedPost: ${selectedPost},
sortedPosts: ${sortedPosts},
totalPosts: ${totalPosts},
totalLikes: ${totalLikes}
    ''';
  }
}
