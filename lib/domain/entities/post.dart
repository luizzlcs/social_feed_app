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
  
  // ✅ NOVO: Flags para UI otimista
  final bool isOptimistic;
  final bool syncFailed;
  final String? syncError;

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
    this.isOptimistic = false, // ✅ NOVO
    this.syncFailed = false,    // ✅ NOVO
    this.syncError,             // ✅ NOVO
  });

  Post copyWith({
    String? id,
    String? userId,
    String? username,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? comments,
    String? imageUrl,
    bool? isOptimistic, // ✅ NOVO
    bool? syncFailed,    // ✅ NOVO
    String? syncError,   // ✅ NOVO
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
      isOptimistic: isOptimistic ?? this.isOptimistic, // ✅ NOVO
      syncFailed: syncFailed ?? this.syncFailed,        // ✅ NOVO
      syncError: syncError ?? this.syncError,           // ✅ NOVO
    );
  }
}