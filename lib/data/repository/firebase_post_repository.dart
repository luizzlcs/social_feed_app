import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/data/repository/services/post_comment_service.dart';
import 'package:social_feed_app/data/repository/services/post_crud_service.dart';
import 'package:social_feed_app/data/repository/services/post_image_service.dart';
import 'package:social_feed_app/data/repository/services/post_like_service.dart';
import 'package:social_feed_app/domain/entities/post.dart';

class FirebasePostRepository {
  final PostCrudService _crudService;
  final PostLikeService _likeService;
  final PostCommentService _commentService;
  final PostImageService _imageService;

  FirebasePostRepository(FirebaseService firebaseService)
      : _crudService = PostCrudService(firebaseService),
        _likeService = PostLikeService(firebaseService),
        _commentService = PostCommentService(firebaseService),
        _imageService = PostImageService(firebaseService);

  // === STREAMS E CONSULTAS ===
  
  Stream<List<Post>> getPostsStream({String? currentUserId}) {
    return _crudService.getPostsStream(currentUserId: currentUserId);
  }

  Future<List<Post>> getPosts({
    int limit = 10,
    DocumentSnapshot? lastDocument,
    String? currentUserId,
  }) {
    return _crudService.getPosts(
      limit: limit,
      lastDocument: lastDocument,
      currentUserId: currentUserId,
    );
  }

  Future<List<Post>> getPostsLikedByUser(String userId) {
    return _likeService.getPostsLikedByUser(userId);
  }

  // === CRUD DE POSTS ===
  
  Future<Post> createPost(Post post, {String? imagePath}) async {
    final imageUrl = await _imageService.uploadImageIfNeeded(imagePath, post.id);
    return _crudService.createPost(post, imageUrl);
  }

  Future<Post> updatePost(Post post) {
    return _crudService.updatePost(post);
  }

  Future<void> deletePost(String postId) async {
    await _imageService.deletePostImage(postId);
    await _commentService.deletePostComments(postId);
    await _crudService.deletePost(postId);
  }

  // === LIKES (CURTIDAS) ===
  
  Future<void> toggleLike(String postId, String userId) {
    return _likeService.toggleLike(postId, userId);
  }

  Future<bool> hasUserLikedPost(String postId, String userId) {
    return _likeService.hasUserLikedPost(postId, userId);
  }

  Future<int?> getUserLikeCount(String userId) {
    return _likeService.getUserLikeCount(userId);
  }

  // === COMENTÁRIOS ===
  
  Future<void> addComment(String postId, String userId, String comment) {
    return _commentService.addComment(postId, userId, comment);
  }

  // === MÉTODOS DE CONSULTA SIMPLES ===
  
  Future<Post?> getPostById(String postId) {
    return _crudService.getPostById(postId);
  }

  Future<int?> getTotalPostsCount() {
    return _crudService.getTotalPostsCount();
  }
}