import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/domain/entities/post.dart';

class FirebasePostRepository {
  final FirebaseService _firebaseService;
  
  FirebasePostRepository(this._firebaseService);

  // ✅ ATUALIZADO: Stream de posts com informações de curtidas
  Stream<List<Post>> getPostsStream({String? currentUserId}) {
    return _firebaseService.postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _convertDocumentToPost(doc, currentUserId: currentUserId))
              .toList();
        });
  }

  // ✅ ATUALIZADO: Buscar posts com informações de curtidas do usuário
  Future<List<Post>> getPosts({
    int limit = 10,
    DocumentSnapshot? lastDocument,
    String? currentUserId, // ✅ NOVO: para saber se usuário já curtiu
  }) async {
    try {
      if (kDebugMode) {
        print('📄 getPosts: limit=$limit, userId=${currentUserId ?? "null"}');
      }
      
      var query = _firebaseService.postsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      
      if (kDebugMode) {
        print('✅ getPosts: ${snapshot.docs.length} documentos encontrados');
      }
      
      return snapshot.docs
          .map((doc) => _convertDocumentToPost(doc, currentUserId: currentUserId))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em getPosts: $e');
      }
      rethrow;
    }
  }

  // ✅ ATUALIZADO: Converter documento com campo likedBy
  Post _convertDocumentToPost(DocumentSnapshot doc, {String? currentUserId}) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      
      // Converte Timestamp para DateTime
      Timestamp? createdAt = data['createdAt'];
      Timestamp? updatedAt = data['updatedAt'];
      
      // ✅ NOVO: Extrai lista de quem curtiu
      List<String> likedBy = [];
      final likedByData = data['likedBy'];
      if (likedByData is List) {
        likedBy = likedByData.map((e) => e.toString()).toList();
      }
      
      // ✅ NOVO: Verifica se usuário atual já curtiu (para UI)
      bool isLikedByCurrentUser = currentUserId != null && likedBy.contains(currentUserId);
      
      return Post(
        id: doc.id,
        userId: data['userId']?.toString() ?? '',
        username: data['username']?.toString() ?? 'Usuário',
        content: data['content']?.toString() ?? '',
        imageUrl: data['imageUrl']?.toString(),
        createdAt: createdAt?.toDate() ?? DateTime.now(),
        updatedAt: updatedAt?.toDate() ?? DateTime.now(),
        likes: (data['likes'] ?? 0).toInt(),
        comments: (data['comments'] ?? 0).toInt(),
        likedBy: likedBy, // ✅ NOVO: Campo adicionado
        isOptimistic: isLikedByCurrentUser, // ✅ Usado para marcar se usuário curtiu
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em _convertDocumentToPost: $e');
        print('Dados do documento: ${doc.data()}');
      }
      rethrow;
    }
  }

  // ✅ ATUALIZADO: Criar post com campo likedBy
  Future<Post> createPost(Post post, {String? imagePath}) async {
    if (kDebugMode) {
      print('🎯 REPOSITORY: Iniciando createPost');
      print('📝 Post ID: ${post.id}');
      print('👤 User ID: ${post.userId}');
      print('👤 Username: ${post.username}');
      print('📄 Content: ${post.content}');
      print('🖼️ Image Path: ${imagePath?.substring(0, 50)}...');
    }
    
    try {
      String? imageUrl;
      
      // Upload da imagem se houver
      if (imagePath != null && imagePath.isNotEmpty) {
        if (kDebugMode) print('🖼️ Fazendo upload da imagem...');
        imageUrl = await _uploadImage(imagePath, post.id);
        if (kDebugMode) print('✅ Imagem upload: ${imageUrl?.substring(0, 80)}...');
      }

      // ✅ ATUALIZADO: Inclui campo likedBy (inicialmente vazio)
      final postData = {
        'userId': post.userId,
        'username': post.username,
        'content': post.content,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': post.likes,
        'comments': post.comments,
        'likedBy': [], // ✅ NOVO: Array vazio inicial
      };

      if (kDebugMode) {
        print('📦 Dados para Firestore:');
        print('  userId: ${postData['userId']}');
        print('  username: ${postData['username']}');
        print('  content: ${postData['content']}');
        print('  imageUrl: ${postData['imageUrl']}');
        print('  likedBy: [] (inicial)'); // ✅ NOVO
      }

      // Salvar no Firestore
      if (kDebugMode) print('💾 Salvando no Firestore...');
      await _firebaseService.postsCollection.doc(post.id).set(postData);
      
      if (kDebugMode) print('✅ Post salvo no Firestore!');
      
      // Retorna o post com a URL da imagem e likedBy vazio
      return post.copyWith(
        imageUrl: imageUrl,
        likedBy: [], // ✅ Garante que likedBy está inicializado
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌❌❌ ERRO em createPost: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // ✅ ATUALIZADO: Atualizar post mantendo likedBy
  Future<Post> updatePost(Post post) async {
    try {
      final postData = {
        'userId': post.userId,
        'username': post.username,
        'content': post.content,
        'imageUrl': post.imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': post.likes,
        'comments': post.comments,
        'likedBy': post.likedBy, // ✅ NOVO: Inclui lista de curtidas
      };

      await _firebaseService.postsCollection
          .doc(post.id)
          .update(postData);
      
      return post;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em updatePost: $e');
      }
      rethrow;
    }
  }

  // ✅ NOVO: Curtir/Descurtir post (toggle)
  Future<void> toggleLike(String postId, String userId) async {
    try {
      if (kDebugMode) {
        print('❤️ Toggle like: post=$postId, user=$userId');
      }
      
      // Primeiro obtém o post atual para verificar estado
      final post = await getPostById(postId);
      
      if (post != null) {
        final alreadyLiked = post.likedBy.contains(userId);
        
        if (alreadyLiked) {
          // ✅ Descurtir: remove da lista e decrementa contador
          await _firebaseService.postsCollection.doc(postId).update({
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([userId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          if (kDebugMode) print('💔 Like removido');
        } else {
          // ✅ Curtir: adiciona na lista e incrementa contador
          await _firebaseService.postsCollection.doc(postId).update({
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([userId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          if (kDebugMode) print('💖 Like adicionado');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em toggleLike: $e');
      }
      rethrow;
    }
  }

  // ✅ NOVO: Obter posts curtidos por um usuário específico
  Future<List<Post>> getPostsLikedByUser(String userId) async {
    try {
      if (kDebugMode) {
        print('🔍 Buscando posts curtidos por: $userId');
      }
      
      final snapshot = await _firebaseService.postsCollection
          .where('likedBy', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      if (kDebugMode) {
        print('✅ Posts curtidos: ${snapshot.docs.length} encontrados');
      }
      
      return snapshot.docs
          .map((doc) => _convertDocumentToPost(doc, currentUserId: userId))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em getPostsLikedByUser: $e');
      }
      rethrow;
    }
  }

  // ✅ NOVO: Verificar se usuário curtiu um post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    try {
      final post = await getPostById(postId);
      return post?.likedBy.contains(userId) ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ ERRO em hasUserLikedPost: $e');
      }
      return false;
    }
  }

  // ✅ NOVO: Obter contagem de curtidas de um usuário
  Future<int?> getUserLikeCount(String userId) async {
    try {
      final snapshot = await _firebaseService.postsCollection
          .where('likedBy', arrayContains: userId)
          .count()
          .get();
      
      return snapshot.count;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ ERRO em getUserLikeCount: $e');
      }
      return 0;
    }
  }

  // ✅ MANTIDO: Upload de imagem
  Future<String> _uploadImage(String imagePath, String postId) async {
    if (kDebugMode) {
      print('🎯 REPOSITORY: Iniciando _uploadImage');
      print('📁 Post ID: $postId');
    }
    
    try {
      final fileName = 'post_${postId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      if (kDebugMode) print('📁 File name: $fileName');
      
      final Reference storageRef = _firebaseService.storage
          .ref()
          .child('posts')
          .child(fileName);
      
      UploadTask uploadTask;
      
      if (imagePath.startsWith('data:image')) {
        final base64String = imagePath.split(',').last;
        final bytes = base64.decode(base64String);
        
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else if (imagePath.startsWith('http')) {
        return imagePath;
      } else {
        final file = File(imagePath);
        uploadTask = storageRef.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      
      if (kDebugMode) print('⏳ Aguardando upload...');
      final snapshot = await uploadTask;
      if (kDebugMode) print('✅ Upload completo!');
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      final cleanedUrl = _cleanFirebaseUrl(downloadUrl);
      
      if (kDebugMode) {
        print('🔗 Download URL (limpa): ${cleanedUrl.substring(0, 80)}...');
      }
      
      return cleanedUrl;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌❌❌ ERRO em _uploadImage: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // ✅ MANTIDO: Limpar URL do Firebase
  String _cleanFirebaseUrl(String url) {
    return url.replaceAll('\n', '').replaceAll('\r', '').trim();
  }

  // ✅ MANTIDO: Obter post por ID (agora com likedBy)
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firebaseService.postsCollection.doc(postId).get();
      if (doc.exists) {
        return _convertDocumentToPost(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em getPostById: $e');
      }
      rethrow;
    }
  }

  // ✅ MANTIDO: Obter último documento para paginação
  Future<DocumentSnapshot?> getLastDocumentSnapshot() async {
    try {
      final snapshot = await _firebaseService.postsCollection
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ ERRO em getLastDocumentSnapshot: $e');
      }
      return null;
    }
  }

  // ✅ MANTIDO: Deletar post
  Future<void> deletePost(String postId) async {
    try {
      await _deletePostImage(postId);
      await _firebaseService.postsCollection.doc(postId).delete();
      await _deletePostComments(postId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em deletePost: $e');
      }
      rethrow;
    }
  }

  // ✅ MANTIDO: Adicionar comentário
  Future<void> addComment(String postId, String userId, String comment) async {
    try {
      final commentData = {
        'postId': postId,
        'userId': userId,
        'comment': comment,
        'createdAt': Timestamp.now(),
      };
      
      await _firebaseService.commentsCollection.add(commentData);
      
      await _firebaseService.postsCollection.doc(postId).update({
        'comments': FieldValue.increment(1),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em addComment: $e');
      }
      rethrow;
    }
  }

  // ✅ MANTIDO: Deletar imagem do Storage
  Future<void> _deletePostImage(String postId) async {
    try {
      final listResult = await _firebaseService.storage
          .ref()
          .child('posts')
          .listAll();
      
      for (var item in listResult.items) {
        if (item.name.contains(postId)) {
          await item.delete();
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao deletar imagem (pode não existir): $e');
      }
    }
  }

  // ✅ MANTIDO: Deletar comentários
  Future<void> _deletePostComments(String postId) async {
    try {
      final query = await _firebaseService.commentsCollection
          .where('postId', isEqualTo: postId)
          .get();
      
      final batch = _firebaseService.firestore.batch();
      
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao deletar comentários: $e');
      }
    }
  }

  // ✅ MANTIDO: Contar total de posts
  Future<int?> getTotalPostsCount() async {
    try {
      final snapshot = await _firebaseService.postsCollection.count().get();
      return snapshot.count;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ ERRO em getTotalPostsCount: $e');
      }
      return 0;
    }
  }
}