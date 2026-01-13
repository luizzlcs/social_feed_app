import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/data/repository/utils/firebase_logger.dart';

class PostCommentService {
  final FirebaseService _firebaseService;
  final FirebaseLogger _logger = FirebaseLogger();
  
  CollectionReference get _postsCollection => _firebaseService.postsCollection;
  CollectionReference get _commentsCollection => _firebaseService.commentsCollection;

  PostCommentService(this._firebaseService);

  Future<void> addComment(String postId, String userId, String comment) async {
    try {
      final commentData = {
        'postId': postId,
        'userId': userId,
        'comment': comment,
        'createdAt': Timestamp.now(),
      };
      
      await _commentsCollection.add(commentData);
      await _incrementCommentsCount(postId);
      
      _logger.log('💬 Comentário adicionado ao post $postId');
    } catch (e) {
      _logger.logError('addComment', e);
      rethrow;
    }
  }

  Future<void> deletePostComments(String postId) async {
    try {
      final query = await _commentsCollection
          .where('postId', isEqualTo: postId)
          .get();
      
      final batch = _firebaseService.firestore.batch();
      
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      _logger.log('🗑️ Comentários do post $postId deletados');
    } catch (e) {
      _logger.logWarning('deletePostComments', e);
    }
  }

  Future<void> _incrementCommentsCount(String postId) async {
    await _postsCollection.doc(postId).update({
      'comments': FieldValue.increment(1),
    });
  }
}