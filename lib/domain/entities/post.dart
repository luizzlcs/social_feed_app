import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int comments;
  final String? imageUrl;

  const Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.likes = 0,
    this.comments = 0,
    this.imageUrl,
  });

  // Método para criar cópia com alterações (útil para edição)
  Post copyWith({
    String? id,
    String? userId,
    String? username,
    String? content,
    DateTime? createdAt,
    int? likes,
    int? comments,
    String? imageUrl,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}