import 'package:social_feed_app/domain/entities/post.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final String? imageUrl;

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.imageUrl,
  });

  // Converte Model para Entity
  Post toEntity() {
    return Post(
      id: id,
      userId: userId,
      username: username,
      content: content,
      createdAt: createdAt,
      likes: likes,
      comments: comments,
      imageUrl: imageUrl,
    );
  }

  // Converte Entity para Model
  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      userId: post.userId,
      username: post.username,
      content: post.content,
      createdAt: post.createdAt,
      likes: post.likes,
      comments: post.comments,
      imageUrl: post.imageUrl,
    );
  }

  // Converte JSON para Model (simulação - depois virá de API)
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'Usuário',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  // Converte Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'imageUrl': imageUrl,
    };
  }
}