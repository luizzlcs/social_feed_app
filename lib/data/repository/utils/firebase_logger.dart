import 'package:flutter/foundation.dart';

class FirebaseLogger {
  /// Log simples para debug
  void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  /// Log de erros
  void logError(String methodName, dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERRO em $methodName: $error');
      if (stackTrace != null) print('Stack trace: $stackTrace');
    }
  }

  /// Log de avisos
  void logWarning(String methodName, dynamic error) {
    if (kDebugMode) {
      print('⚠️ AVISO em $methodName: $error');
    }
  }

  /// Log de detalhes do post
  void logDetails(String postId, String userId, String username, String content) {
    if (kDebugMode) {
      print('📝 Post ID: $postId');
      print('👤 User ID: $userId');
      print('👤 Username: $username');
      print('📄 Content: $content');
    }
  }

  /// Log dos dados do post
  void logPostData(Map<String, dynamic> postData) {
    if (kDebugMode) {
      print('📦 Dados do post:');
      print('  userId: ${postData['userId']}');
      print('  username: ${postData['username']}');
      print('  content: ${postData['content']}');
      print('  imageUrl: ${postData['imageUrl'] ?? "null"}');
      print('  likedBy: ${postData['likedBy']?.length ?? 0} curtidas');
    }
  }
}