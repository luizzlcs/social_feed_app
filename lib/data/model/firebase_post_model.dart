import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_feed_app/domain/entities/post.dart';

class FirebasePostModel {
  final String id;
  final String userId;
  final String username;
  final String content;
  final String? imageUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final int likes;
  final int comments;
  final Map<String, dynamic>? location;

  FirebasePostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.likes = 0,
    this.comments = 0,
    this.location,
  });

  // Converte para Entity
  Post toEntity() {
    return Post(
      id: id,
      userId: userId,
      username: username,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
      likes: likes,
      comments: comments,
    );
  }

  // Converte de Entity para Firebase Model
  factory FirebasePostModel.fromEntity(Post post) {
    return FirebasePostModel(
      id: post.id,
      userId: post.userId,
      username: post.username,
      content: post.content,
      imageUrl: post.imageUrl,
      createdAt: Timestamp.fromDate(post.createdAt),
      updatedAt: Timestamp.fromDate(post.updatedAt),
      likes: post.likes,
      comments: post.comments,
    );
  }

  // Converte de DocumentSnapshot (versão corrigida)
  factory FirebasePostModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    
    return FirebasePostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Usuário',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      likes: (data['likes'] ?? 0).toInt(),
      comments: (data['comments'] ?? 0).toInt(),
      location: data['location'],
    );
  }

  // Versão alternativa que aceita QueryDocumentSnapshot
  factory FirebasePostModel.fromQueryDocumentSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    
    return FirebasePostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Usuário',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      likes: (data['likes'] ?? 0).toInt(),
      comments: (data['comments'] ?? 0).toInt(),
      location: data['location'],
    );
  }

  // Converte para Map (para salvar no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'likes': likes,
      'comments': comments,
      'location': location,
    };
  }
}