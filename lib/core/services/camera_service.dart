import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> takePhoto() async {
    try {
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        throw Exception('Câmera não suportada nesta plataforma');
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      return photo;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao tirar foto: $e');
      }
      rethrow;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao selecionar imagem: $e');
      }
      rethrow;
    }
  }

  // Método que SEMPRE retorna uma string que funciona em todas as plataformas
  Future<String?> getPlatformCompatibleImage(XFile? xfile) async {
    if (xfile == null) return null;
    
    try {
      if (kIsWeb) {
        // Na web, converte para data URL
        final bytes = await xfile.readAsBytes();
        final base64 = base64Encode(bytes);
        final mimeType = _getMimeType(xfile.name);
        return 'data:$mimeType;base64,$base64';
      } else {
        // No mobile, retorna o caminho do arquivo
        return xfile.path;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao converter imagem: $e');
      }
      return null;
    }
  }

  String _getMimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }

  // Verifica se a plataforma suporta câmera
  bool isCameraAvailable() {
    return kIsWeb || Platform.isAndroid || Platform.isIOS;
  }

  // Retorna o tipo de plataforma
  String getPlatformInfo() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Outro';
  }
}