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
  
  // ✅ ADICIONAR: Campo likedBy do Firebase
  final List<String> likedBy;

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
    this.likedBy = const [], // ✅ NOVO: Inicializar como lista vazia
  });

  // ✅ CORRIGIDO: Converte para Entity com todos os campos
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
      
      // ✅ IMPORTANTE: Converter likedBy do Firebase
      likedBy: likedBy,
      
      // ✅ CRÍTICO: Posts do Firebase NUNCA são otimistas
      isOptimistic: false,
      
      syncFailed: false,
      syncError: null,
    );
  }

  // ✅ CORRIGIDO: Converte de Entity para Firebase Model
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
      
      // ✅ IMPORTANTE: Incluir likedBy
      likedBy: post.likedBy,
      
      // ⚠️ NÃO incluir location se não existe no Post entity
      // location: null,
    );
  }

  // ✅ CORRIGIDO: Converte de DocumentSnapshot
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
      
      // ✅ IMPORTANTE: Carregar likedBy do Firebase
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  // ✅ CORRIGIDO: Versão para QueryDocumentSnapshot
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
      
      // ✅ IMPORTANTE: Carregar likedBy do Firebase
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  // ✅ CORRIGIDO: Converte para Map (para salvar no Firestore)
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'userId': userId,
      'username': username,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'likes': likes,
      'comments': comments,
      
      // ✅ IMPORTANTE: Salvar likedBy no Firebase
      'likedBy': likedBy,
    };
    
    // Adicionar location apenas se não for null
    if (location != null) {
      map['location'] = location;
    }
    
    return map;
  }
}