import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/data/repository/utils/firebase_logger.dart';
import 'package:social_feed_app/domain/entities/post.dart';

class PostCrudService {
  final FirebaseService _firebaseService;
  final FirebaseLogger _logger = FirebaseLogger();
  
  CollectionReference get _postsCollection => _firebaseService.postsCollection;

  PostCrudService(this._firebaseService);

  // === STREAMS E CONSULTAS ===
  
  Stream<List<Post>> getPostsStream({String? currentUserId}) {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _convertDocsToList(snapshot.docs, currentUserId));
  }

  Future<List<Post>> getPosts({
    int limit = 10,
    DocumentSnapshot? lastDocument,
    String? currentUserId,
  }) async {
    _logger.log('📄 Buscando posts: limit=$limit, userId=${currentUserId ?? "null"}');
    
    try {
      var query = _postsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      _logger.log('✅ ${snapshot.docs.length} posts encontrados');
      
      return _convertDocsToList(snapshot.docs, currentUserId);
    } catch (e) {
      _logger.logError('getPosts', e);
      rethrow;
    }
  }

  // === OPERAÇÕES CRUD ===
  
  Future<Post> createPost(Post post, String? imageUrl) async {
    _logger.log('🎯 Criando post: ${post.id}');
    
    try {
      final postData = _createPostData(post, imageUrl);
      _logger.logPostData(postData);
      
      await _postsCollection.doc(post.id).set(postData);
      _logger.log('✅ Post criado com sucesso!');
      
      return post.copyWith(imageUrl: imageUrl, likedBy: []);
    } catch (e, stackTrace) {
      _logger.logError('createPost', e, stackTrace);
      rethrow;
    }
  }

  Future<Post> updatePost(Post post) async {
    try {
      final postData = _createPostData(post, post.imageUrl);
      await _postsCollection.doc(post.id).update(postData);
      return post;
    } catch (e) {
      _logger.logError('updatePost', e);
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).delete();
      _logger.log('🗑️ Post $postId deletado');
    } catch (e) {
      _logger.logError('deletePost', e);
      rethrow;
    }
  }

  // === CONSULTAS SIMPLES ===
  
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      return doc.exists ? _convertDocumentToPost(doc) : null;
    } catch (e) {
      _logger.logError('getPostById', e);
      rethrow;
    }
  }

  Future<int?> getTotalPostsCount() async {
    try {
      final snapshot = await _postsCollection.count().get();
      return snapshot.count;
    } catch (e) {
      _logger.logWarning('getTotalPostsCount', e);
      return 0;
    }
  }

  // === MÉTODOS AUXILIARES PRIVADOS ===
  
  List<Post> _convertDocsToList(List<DocumentSnapshot> docs, String? currentUserId) {
    return docs
        .map((doc) => _convertDocumentToPost(doc, currentUserId: currentUserId))
        .toList();
  }

  Post _convertDocumentToPost(DocumentSnapshot doc, {String? currentUserId}) {
    try {
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
    } catch (e) {
      _logger.logError('_convertDocumentToPost', e);
      rethrow;
    }
  }

  List<String> _extractLikedByList(Map<String, dynamic> data) {
    final likedByData = data['likedBy'];
    if (likedByData is List) {
      return likedByData.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> _createPostData(Post post, String? imageUrl) {
    return {
      'userId': post.userId,
      'username': post.username,
      'content': post.content,
      'imageUrl': imageUrl,
      'createdAt': post.createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'likes': post.likes,
      'comments': post.comments,
      'likedBy': post.likedBy,
    };
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }
}