import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/data/repository/utils/firebase_logger.dart';

class PostImageService {
  final FirebaseService _firebaseService;
  final FirebaseLogger _logger = FirebaseLogger();
  
  FirebaseStorage get _storage => _firebaseService.storage;

  PostImageService(this._firebaseService);

  Future<String?> uploadImageIfNeeded(String? imagePath, String postId) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    _logger.log('🖼️ Fazendo upload da imagem...');
    
    try {
      // Se já for uma URL, retorna direto
      if (imagePath.startsWith('http')) {
        return imagePath;
      }

      final fileName = 'post_${postId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('posts').child(fileName);
      
      final uploadTask = _createUploadTask(imagePath, storageRef);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return _cleanFirebaseUrl(downloadUrl);
    } catch (e, stackTrace) {
      _logger.logError('uploadImageIfNeeded', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePostImage(String postId) async {
    try {
      final listResult = await _storage.ref().child('posts').listAll();
      
      for (var item in listResult.items) {
        if (item.name.contains(postId)) {
          await item.delete();
          _logger.log('🖼️ Imagem do post $postId deletada');
          break;
        }
      }
    } catch (e) {
      _logger.logWarning('deletePostImage', e);
    }
  }

  // === MÉTODOS AUXILIARES PRIVADOS ===
  
  UploadTask _createUploadTask(String imagePath, Reference storageRef) {
    if (imagePath.startsWith('data:image')) {
      final base64String = imagePath.split(',').last;
      final bytes = base64.decode(base64String);
      
      return storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    } else {
      final file = File(imagePath);
      return storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    }
  }

  String _cleanFirebaseUrl(String url) {
    return url.replaceAll('\n', '').replaceAll('\r', '').trim();
  }
}