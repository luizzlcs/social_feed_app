import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/pages/post_detail/post_detail_page.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';
import 'package:social_feed_app/presentation/stores/post_store/post_store.dart';
import 'package:social_feed_app/presentation/pages/feed/widgets/feed_app_bar.dart';
import 'package:social_feed_app/presentation/pages/feed/widgets/feed_error_widget.dart';
import 'package:social_feed_app/presentation/pages/feed/widgets/feed_empty_state.dart';
import 'package:social_feed_app/presentation/pages/feed/widgets/feed_loading_widget.dart';
import 'package:social_feed_app/presentation/pages/feed/widgets/feed_stats_widget.dart';
import 'package:social_feed_app/presentation/pages/feed/widgets/processing_posts_widget.dart';
import 'package:social_feed_app/presentation/pages/feed/widgets/post_list_widget.dart';
import 'package:social_feed_app/presentation/pages/feed/dialogs/edit_post_dialog.dart';
import 'package:social_feed_app/presentation/pages/feed/dialogs/delete_post_dialog.dart';
import 'package:social_feed_app/presentation/pages/create_post/create_post_page.dart';
import 'package:social_feed_app/presentation/pages/feed/utils/scroll_handler.dart';

class FeedPage extends StatefulWidget {
  final String username;

  const FeedPage({super.key, required this.username});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final AuthStore _authStore;
  late final PostStore _postStore;
  late final ScrollHandler _scrollHandler;

  @override
  void initState() {
    super.initState();
    _authStore = getIt<AuthStore>();
    _postStore = getIt<PostStore>();
    _scrollHandler = ScrollHandler(_postStore);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postStore.loadPosts();
    });
  }

  @override
  void dispose() {
    _scrollHandler.dispose();
    super.dispose();
  }

  void _showCreatePostDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(
          onPostCreated: (content, imagePath) async {
            await _postStore.createPost(content, imagePath: imagePath);
            _showSuccessSnackBar('Post criado! Sincronizando...');
          },
        ),
      ),
    );
  }

  void _showEditPostDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) => EditPostDialog(
        post: post,
        postStore: _postStore,
        onPostUpdated: () {
          _showSuccessSnackBar('Post atualizado!');
        },
      ),
    );
  }

  void _showDeletePostDialog(String postId) {
    showDialog(
      context: context,
      builder: (context) => DeletePostDialog(
        postId: postId,
        postStore: _postStore,
        onPostDeleted: () {
          _showSuccessSnackBar('Post excluído!');
        },
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeedAppBar(
        postStore: _postStore,
        authStore: _authStore,
        onCreatePost: _showCreatePostDialog,
      ),
      body: Observer(
        builder: (_) => _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_postStore.isLoading && _postStore.allPosts.isEmpty) {
      return const FeedLoadingWidget();
    }

    if (_postStore.errorMessage != null && _postStore.allPosts.isEmpty) {
      return FeedErrorWidget(
        errorMessage: _postStore.errorMessage!,
        onRetry: _postStore.loadPosts,
      );
    }

    if (_postStore.allPosts.isEmpty) {
      return FeedEmptyState(onCreatePost: _showCreatePostDialog);
    }

    return _buildFeedContent();
  }

  Widget _buildFeedContent() {
    return RefreshIndicator(
      onRefresh: () => _postStore.refreshPosts(),
      child: Column(
        children: [
          FeedStatsWidget(postStore: _postStore),
          ProcessingPostsWidget(postStore: _postStore),
          Expanded(
            child: PostListWidget(
              scrollController: _scrollHandler.controller,
              postStore: _postStore,
              onPostTap: (post) => _navigateToPostDetail(post),
              onPostLike: (postId) => _postStore.likePost(postId),
              onPostComment: (postId) => _postStore.addComment(postId),
              onPostEdit: _showEditPostDialog,
              onPostDelete: _showDeletePostDialog,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPostDetail(Post post) {
    if (!post.isOptimistic) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailPage(postId: post.id),
        ),
      );
    }
  }
}