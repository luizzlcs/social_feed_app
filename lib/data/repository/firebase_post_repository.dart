import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/data/model/firebase_post_model.dart';
import 'package:social_feed_app/domain/entities/post.dart';

class FirebasePostRepository {
  final FirebaseService _firebaseService;
  
  FirebasePostRepository(this._firebaseService);

  // ✅ CORRIGIDO: Stream de posts
  // Stream de posts em tempo real
  Stream<List<Post>> getPostsStream() {
    return _firebaseService.postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _convertDocumentToPost(doc))
              .toList();
        });
  }

  // Buscar posts paginados
  Future<List<Post>> getPosts({int limit = 20, DocumentSnapshot? lastDoc}) async {
    try {
      var query = _firebaseService.postsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => _convertDocumentToPost(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em getPosts: $e');
      }
      rethrow;
    }
  }

  // Método para converter documento em Post
  Post _convertDocumentToPost(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Converte Timestamp para DateTime
    Timestamp? createdAt = data['createdAt'];
    Timestamp? updatedAt = data['updatedAt'];
    
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
    );
  }

  // Buscar post por ID
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

  // Criar novo post
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
        if (kDebugMode) print('✅ Imagem upload: $imageUrl');
      }

      // Usar FieldValue.serverTimestamp()
      final postData = {
        'userId': post.userId,
        'username': post.username,
        'content': post.content,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': post.likes,
        'comments': post.comments,
      };

      if (kDebugMode) {
        print('📦 Dados para Firestore:');
        print('  userId: ${postData['userId']}');
        print('  username: ${postData['username']}');
        print('  content: ${postData['content']}');
        print('  imageUrl: ${postData['imageUrl']}');
        print('  createdAt: SERVER_TIMESTAMP');
        print('  updatedAt: SERVER_TIMESTAMP');
      }

      // Salvar no Firestore
      if (kDebugMode) print('💾 Salvando no Firestore...');
      await _firebaseService.postsCollection.doc(post.id).set(postData);
      
      if (kDebugMode) print('✅ Post salvo no Firestore!');
      
      // Verificar se foi salvo
      final savedDoc = await _firebaseService.postsCollection.doc(post.id).get();
      if (savedDoc.exists) {
        if (kDebugMode) {
          print('✅✅✅ POST SALVO E CONFIRMADO!');
          print('📄 Dados salvos: ${savedDoc.data()}');
        }
      } else {
        if (kDebugMode) print('❌ POST NÃO ENCONTRADO APÓS SALVAR!');
      }
      
      // Retorna o post com a URL da imagem
      return post.copyWith(imageUrl: imageUrl);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌❌❌ ERRO em createPost: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // Atualizar post
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

  // Deletar post
  Future<void> deletePost(String postId) async {
    try {
      // Primeiro deleta a imagem do storage se existir
      await _deletePostImage(postId);
      
      // Depois deleta o post do firestore
      await _firebaseService.postsCollection.doc(postId).delete();
      
      // Opcional: deletar comentários relacionados
      await _deletePostComments(postId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em deletePost: $e');
      }
      rethrow;
    }
  }

  // Curtir post
  Future<void> likePost(String postId, String userId) async {
    try {
      await _firebaseService.postsCollection.doc(postId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ ERRO em likePost: $e');
      }
      rethrow;
    }
  }

  // Adicionar comentário
  Future<void> addComment(String postId, String userId, String comment) async {
    try {
      final commentData = {
        'postId': postId,
        'userId': userId,
        'comment': comment,
        'createdAt': Timestamp.now(),
      };
      
      await _firebaseService.commentsCollection.add(commentData);
      
      // Incrementa contador de comentários no post
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

  // Upload de imagem para Firebase Storage
  Future<String> _uploadImage(String imagePath, String postId) async {
    if (kDebugMode) {
      print('🎯 REPOSITORY: Iniciando _uploadImage');
      print('📁 Post ID: $postId');
      print('📍 Image path type: ${imagePath.startsWith('data:image') ? 'Data URL' : 'File path'}');
    }
    
    try {
      // Gera um nome único para a imagem
      final fileName = 'post_${postId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      if (kDebugMode) print('📁 File name: $fileName');
      
      final Reference storageRef = _firebaseService.storage
          .ref()
          .child('posts')
          .child(fileName);
      
      if (kDebugMode) print('📍 Storage path: ${storageRef.fullPath}');
      
      UploadTask uploadTask;
      
      if (imagePath.startsWith('data:image')) {
        // Data URL (Web) - converte para bytes
        if (kDebugMode) print('🌐 Convertendo Data URL para bytes...');
        final base64String = imagePath.split(',').last;
        final bytes = base64.decode(base64String);
        if (kDebugMode) print('📊 Bytes length: ${bytes.length}');
        
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else if (imagePath.startsWith('http')) {
        // Já é uma URL - retorna direto
        if (kDebugMode) print('🌐 Já é URL HTTP, retornando...');
        return imagePath;
      } else {
        // File path (Mobile)
        if (kDebugMode) print('📱 Lendo arquivo do sistema...');
        final file = File(imagePath);
        if (kDebugMode) print('📊 File exists: ${file.existsSync()}');
        if (kDebugMode) print('📊 File size: ${file.lengthSync()} bytes');
        
        uploadTask = storageRef.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      
      if (kDebugMode) print('⏳ Aguardando upload...');
      final snapshot = await uploadTask;
      if (kDebugMode) print('✅ Upload completo! Bytes: ${snapshot.bytesTransferred}');
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      if (kDebugMode) print('🔗 Download URL obtida: $downloadUrl');
      
      return downloadUrl;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌❌❌ ERRO em _uploadImage: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // Deletar imagem do Storage
  Future<void> _deletePostImage(String postId) async {
    try {
      // Busca referência da imagem
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
      // Não lança erro - pode não ter imagem
      if (kDebugMode) {
        print('⚠️ Erro ao deletar imagem (pode não existir): $e');
      }
    }
  }

  // Deletar comentários do post
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
      // Não lança erro - comentários são opcionais
      if (kDebugMode) {
        print('⚠️ Erro ao deletar comentários: $e');
      }
    }
  }
}