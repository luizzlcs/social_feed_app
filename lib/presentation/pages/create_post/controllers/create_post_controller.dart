import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/core/services/camera_service.dart';

class CreatePostController {
  final CameraService _cameraService = getIt<CameraService>();
  
  String? imagePath;
  bool isLoading = false;
  
  ValueNotifier<String?> imagePathNotifier = ValueNotifier(null);
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  /// Verifica se a câmera está disponível
  bool get isCameraAvailable => _cameraService.isCameraAvailable();
  
  /// Obtém informações da plataforma
  String get platformInfo => _cameraService.getPlatformInfo();

  /// Processa uma imagem selecionada
  Future<void> processImage(XFile? image) async {
    if (image == null) return;

    try {
      final imageUrl = await _cameraService.getPlatformCompatibleImage(image);
      if (imageUrl != null) {
        imagePath = imageUrl;
        imagePathNotifier.value = imageUrl;
      }
    } catch (e) {
      throw Exception('Erro ao processar imagem: $e');
    }
  }

  /// Tira foto com a câmera
  Future<void> takePhoto() async {
    if (!isCameraAvailable) {
      throw Exception('Câmera não disponível');
    }

    final photo = await _cameraService.takePhoto();
    await processImage(photo);
  }

  /// Escolhe imagem da galeria
  Future<void> pickFromGallery() async {
    final image = await _cameraService.pickImageFromGallery();
    await processImage(image);
  }

  /// Remove imagem selecionada
  void removeImage() {
    imagePath = null;
    imagePathNotifier.value = null;
  }

  /// Inicia loading
  void startLoading() {
    isLoading = true;
    isLoadingNotifier.value = true;
  }

  /// Para loading
  void stopLoading() {
    isLoading = false;
    isLoadingNotifier.value = false;
  }

  /// Valida conteúdo do post
  String? validateContent(String content) {
    if (content.trim().isEmpty) {
      return 'Por favor, escreva algo no post';
    }
    return null;
  }

  /// Limpa recursos
  void dispose() {
    imagePathNotifier.dispose();
    isLoadingNotifier.dispose();
  }
}