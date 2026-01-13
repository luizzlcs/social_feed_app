// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_store_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PostStoreState on _PostStoreStateBase, Store {
  late final _$postsAtom = Atom(
    name: '_PostStoreStateBase.posts',
    context: context,
  );

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
    name: '_PostStoreStateBase.optimisticPosts',
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
    name: '_PostStoreStateBase.processingPostIds',
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
    name: '_PostStoreStateBase.isLoadingMore',
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
    name: '_PostStoreStateBase.isLoading',
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
    name: '_PostStoreStateBase.errorMessage',
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
    name: '_PostStoreStateBase.selectedPost',
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
    name: '_PostStoreStateBase.hasMorePosts',
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

  late final _$currentUserIdAtom = Atom(
    name: '_PostStoreStateBase.currentUserId',
    context: context,
  );

  @override
  String? get currentUserId {
    _$currentUserIdAtom.reportRead();
    return super.currentUserId;
  }

  @override
  set currentUserId(String? value) {
    _$currentUserIdAtom.reportWrite(value, super.currentUserId, () {
      super.currentUserId = value;
    });
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
currentUserId: ${currentUserId}
    ''';
  }
}
