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
  
  final List<String> likedBy;
  
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
    this.likedBy = const [],
    this.isOptimistic = false,
    this.syncFailed = false,
    this.syncError,
  });

  // Método auxiliar para verificar se usuário curtiu
  bool isLikedBy(String userId) => likedBy.contains(userId);

  // Método auxiliar para verificar se está curtido (mais legível)
  bool get hasLikes => likes > 0;

  String get formattedLikes {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    }
    return likes.toString();
  }

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
    List<String>? likedBy, 
    bool? isOptimistic,
    bool? syncFailed,
    String? syncError,
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
      likedBy: likedBy ?? this.likedBy, 
      isOptimistic: isOptimistic ?? this.isOptimistic,
      syncFailed: syncFailed ?? this.syncFailed,
      syncError: syncError ?? this.syncError,
    );
  }

  Post withLikeAdded(String userId) {
    final newLikedBy = List<String>.from(likedBy);
    if (!newLikedBy.contains(userId)) {
      newLikedBy.add(userId);
    }
    
    return copyWith(
      likes: likes + 1,
      likedBy: newLikedBy,
      updatedAt: DateTime.now(),
    );
  }

  Post withLikeRemoved(String userId) {
    final newLikedBy = List<String>.from(likedBy);
    newLikedBy.remove(userId);
    
    return copyWith(
      likes: likes > 0 ? likes - 1 : 0,
      likedBy: newLikedBy,
      updatedAt: DateTime.now(),
    );
  }

  Post withLikeToggled(String userId) {
    if (likedBy.contains(userId)) {
      return withLikeRemoved(userId);
    } else {
      return withLikeAdded(userId);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Post &&
        other.id == id &&
        other.userId == userId &&
        other.username == username &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.likes == likes &&
        other.comments == comments &&
        other.imageUrl == imageUrl &&
        other.likedBy.length == likedBy.length &&
        other.likedBy.every((userId) => likedBy.contains(userId)) &&
        other.isOptimistic == isOptimistic &&
        other.syncFailed == syncFailed &&
        other.syncError == syncError;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      username,
      content,
      createdAt,
      updatedAt,
      likes,
      comments,
      imageUrl,
      Object.hashAll(likedBy),
      isOptimistic,
      syncFailed,
      syncError,
    );
  }

  @override
  String toString() {
    return 'Post{id: $id, username: $username, likes: $likes, likedBy: ${likedBy.length} users, isOptimistic: $isOptimistic}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'likes': likes,
      'comments': comments,
      'imageUrl': imageUrl,
      'likedBy': likedBy, 
      'isOptimistic': isOptimistic,
      'syncFailed': syncFailed,
      'syncError': syncError,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      userId: map['userId'] as String,
      username: map['username'] as String,
      content: map['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      likes: (map['likes'] ?? 0) as int,
      comments: (map['comments'] ?? 0) as int,
      imageUrl: map['imageUrl'] as String?,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      isOptimistic: (map['isOptimistic'] ?? false) as bool,
      syncFailed: (map['syncFailed'] ?? false) as bool,
      syncError: map['syncError'] as String?,
    );
  }
}