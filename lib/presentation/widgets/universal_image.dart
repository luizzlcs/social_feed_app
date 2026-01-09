import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UniversalImage extends StatelessWidget {
  final String? imageUrl;
  final String? filePath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const UniversalImage({
    super.key,
    this.imageUrl,
    this.filePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : assert(imageUrl != null || filePath != null, 'Deve fornecer imageUrl ou filePath');

  @override
  Widget build(BuildContext context) {
    // Prioridade: imageUrl (para web e network)
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildNetworkImage(imageUrl!);
    }
    
    // Para filePath no mobile
    if (filePath != null && filePath!.isNotEmpty) {
      if (kIsWeb) {
        // Na web, não podemos usar Image.file()
        return _buildWebFileError();
      } else {
        return _buildFileImage(filePath!);
      }
    }
    
    // Fallback
    return _buildErrorWidget('Nenhuma imagem fornecida');
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget('Erro ao carregar imagem'),
    );
  }

  Widget _buildFileImage(String path) {
    return Image.file(
      File(path),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorWidget('Erro ao carregar arquivo');
      },
    );
  }

  Widget _buildWebFileError() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 40, color: Colors.orange),
            const SizedBox(height: 8),
            const Text('Imagem local não suportada na Web'),
            const SizedBox(height: 4),
            Text(
              'Use: $filePath',
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Método helper para criar de uma data URL (web) ou file path (mobile)
  factory UniversalImage.fromPathOrUrl({
    Key? key,
    required String? pathOrUrl,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return UniversalImage(
        key: key,
        imageUrl: null,
        filePath: null,
        height: height,
        width: width,
        fit: fit,
        errorWidget: errorWidget,
      );
    }

    // Verifica se é uma URL da web (http, https) ou data URL (web)
    final isNetworkUrl = pathOrUrl.startsWith('http') || 
                        pathOrUrl.startsWith('https') ||
                        pathOrUrl.startsWith('data:image');

    if (isNetworkUrl) {
      return UniversalImage(
        key: key,
        imageUrl: pathOrUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    } else {
      return UniversalImage(
        key: key,
        filePath: pathOrUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }
  }
}