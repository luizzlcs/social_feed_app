import 'package:flutter/material.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';
import 'package:social_feed_app/presentation/widgets/post_card/post_card.dart';
import 'package:social_feed_app/presentation/pages/post_detail/widgets/post_info_card.dart';
import 'package:social_feed_app/presentation/pages/post_detail/widgets/post_actions_buttons.dart';
import 'package:social_feed_app/presentation/pages/post_detail/widgets/post_author_badge.dart';
import 'package:social_feed_app/presentation/pages/post_detail/widgets/post_header_actions.dart';
import 'package:social_feed_app/presentation/pages/post_detail/widgets/comment_input_widget.dart';
import 'package:social_feed_app/presentation/pages/post_detail/widgets/comments_list_widget.dart';
import 'package:social_feed_app/presentation/pages/post_detail/utils/post_detail_helper.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late final PostStore _postStore;
  late final PostDetailHelper _helper;
  Post? _post;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _postStore = getIt<PostStore>();
    _helper = PostDetailHelper();
    _loadPost();
  }

  void _loadPost() {
    _post = _postStore.findPostById(widget.postId);
    if (_post == null) {
      _post = _helper.createFallbackPost();
    }
  }

  bool get _isCurrentUserPost {
    return _post?.userId == _postStore.currentUserId;
  }

  bool get _canEditPost {
    if (_post == null) return false;
    return _isCurrentUserPost &&
        !_postStore.shouldShowLoading(_post!.id) &&
        !_post!.syncFailed;
  }

  bool get _canDeletePost {
    return _isCurrentUserPost && _post != null;
  }

  void _showEditDialog() {
    if (_post == null || !_canEditPost) return;
    _helper.showEditDialog(
      context: context,
      post: _post!,
      postStore: _postStore,
      onPostUpdated: (updatedContent) {
        setState(() {
          _post = _post!.copyWith(content: updatedContent);
        });
      },
    );
  }

  void _showDeleteDialog() {
    if (!_canDeletePost) return;
    _helper.showDeleteDialog(
      context: context,
      postId: _post!.id,
      postStore: _postStore,
      onPostDeleted: () {
        Navigator.pop(context);
        _helper.showSuccessSnackBar(context, 'Post excluído com sucesso!');
      },
    );
  }

  void _sharePost() {
    _helper.showShareDialog(context);
  }

  void _reportPost() {
    _helper.showReportDialog(context);
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty && _post != null) {
      _helper.addComment(
        _commentController.text.trim(),
        _post!.id,
        _postStore,
        () {
          _commentController.clear();
          FocusScope.of(context).unfocus();
          setState(() {});
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Post'),
        actions: [
          PostHeaderActions(
            isCurrentUserPost: _isCurrentUserPost,
            canEditPost: _canEditPost,
            canDeletePost: _canDeletePost,
            onEdit: _showEditDialog,
            onDelete: _showDeleteDialog,
            onShare: _sharePost,
            onReport: _reportPost,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(
                    post: _post!,
                    showActions: false,
                    onTap: null,
                  ),
                  if (_isCurrentUserPost) PostAuthorBadge(),
                  PostInfoCard(post: _post!, isCurrentUserPost: _isCurrentUserPost),
                  PostActionsButtons(
                    post: _post!,
                    postStore: _postStore,
                    onLike: () => _postStore.likePost(_post!.id),
                    onComment: _addComment,
                  ),
                  CommentsListWidget(post: _post!),
                ],
              ),
            ),
          ),
          CommentInputWidget(
            controller: _commentController,
            onAddComment: _addComment,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}