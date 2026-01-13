import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/data/repository/utils/firebase_logger.dart';
import 'package:social_feed_app/domain/entities/post.dart';

class PostLikeService {
  final FirebaseService _firebaseService;
  final FirebaseLogger _logger = FirebaseLogger();
  
  CollectionReference get _postsCollection => _firebaseService.postsCollection;

  PostLikeService(this._firebaseService);

  Future<void> toggleLike(String postId, String userId) async {
    _logger.log('❤️ Alternando like: post=$postId, user=$userId');
    
    try {
      final post = await _getPostById(postId);
      
      if (post == null) {
        _logger.log('⚠️ Post não encontrado: $postId');
        return;
      }

      final alreadyLiked = post.likedBy.contains(userId);
      
      final updateData = {
        'likes': FieldValue.increment(alreadyLiked ? -1 : 1),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (alreadyLiked) {
        updateData['likedBy'] = FieldValue.arrayRemove([userId]);
        _logger.log('💔 Like removido');
      } else {
        updateData['likedBy'] = FieldValue.arrayUnion([userId]);
        _logger.log('💖 Like adicionado');
      }

      await _postsCollection.doc(postId).update(updateData);
    } catch (e) {
      _logger.logError('toggleLike', e);
      rethrow;
    }
  }

  Future<List<Post>> getPostsLikedByUser(String userId) async {
    _logger.log('🔍 Buscando posts curtidos por: $userId');
    
    try {
      final snapshot = await _postsCollection
          .where('likedBy', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      _logger.log('✅ ${snapshot.docs.length} posts curtidos encontrados');
      
      return snapshot.docs
          .map((doc) => _convertDocumentToPost(doc, currentUserId: userId))
          .toList();
    } catch (e) {
      _logger.logError('getPostsLikedByUser', e);
      rethrow;
    }
  }

  Future<bool> hasUserLikedPost(String postId, String userId) async {
    try {
      final post = await _getPostById(postId);
      return post?.likedBy.contains(userId) ?? false;
    } catch (e) {
      _logger.logWarning('hasUserLikedPost', e);
      return false;
    }
  }

  Future<int?> getUserLikeCount(String userId) async {
    try {
      final snapshot = await _postsCollection
          .where('likedBy', arrayContains: userId)
          .count()
          .get();
      
      return snapshot.count;
    } catch (e) {
      _logger.logWarning('getUserLikeCount', e);
      return 0;
    }
  }

  // === MÉTODOS AUXILIARES PRIVADOS ===
  
  Future<Post?> _getPostById(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (doc.exists) {
        return _convertDocumentToPost(doc);
      }
      return null;
    } catch (e) {
      _logger.logError('_getPostById', e);
      rethrow;
    }
  }

  Post _convertDocumentToPost(DocumentSnapshot doc, {String? currentUserId}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    final likedBy = _extractLikedByList(data);
    final isLikedByCurrentUser = currentUserId != null && likedBy.contains(currentUserId);
    
    return Post(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      username: data['username']?.toString() ?? 'Usuário',
      content: data['content']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString(),
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(data['updatedAt']) ?? DateTime.now(),
      likes: (data['likes'] ?? 0).toInt(),
      comments: (data['comments'] ?? 0).toInt(),
      likedBy: likedBy,
      isOptimistic: isLikedByCurrentUser,
    );
  }

  List<String> _extractLikedByList(Map<String, dynamic> data) {
    final likedByData = data['likedBy'];
    if (likedByData is List) {
      return likedByData.map((e) => e.toString()).toList();
    }
    return [];
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }
}