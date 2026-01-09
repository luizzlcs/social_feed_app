import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:social_feed_app/presentation/widgets/universal_image.dart';

class ImagePreview extends StatelessWidget {
  final String imagePath;
  final bool isNetworkImage;
  final VoidCallback? onRemove;
  final double height;
  final double width;

  const ImagePreview({
    super.key,
    required this.imagePath,
    this.isNetworkImage = false,
    this.onRemove,
    this.height = 200,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: UniversalImage.fromPathOrUrl(
              pathOrUrl: imagePath,
              height: height,
              width: width,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Widget para visualização em tela cheia
class FullScreenImage extends StatelessWidget {
  final String imagePath;
  final bool isNetworkImage;

  const FullScreenImage({
    super.key,
    required this.imagePath,
    this.isNetworkImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: _getImageProvider(),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider() {
    // Se for data URL ou network URL, usa NetworkImage
    if (imagePath.startsWith('http') || 
        imagePath.startsWith('https') ||
        imagePath.startsWith('data:image')) {
      return NetworkImage(imagePath);
    } else {
      // Para mobile, tenta FileImage mas com fallback
      try {
        return NetworkImage(imagePath);
      } catch (e) {
        // Fallback para um placeholder
        return const AssetImage('assets/placeholder.png');
      }
    }
  }
}