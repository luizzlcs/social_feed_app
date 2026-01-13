import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/core/services/camera_service.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';
import 'package:social_feed_app/presentation/widgets/image_preview.dart';

class CreatePostPage extends StatefulWidget {
  final Function(String, String?) onPostCreated;

  const CreatePostPage({super.key, required this.onPostCreated});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final PostStore _postStore = getIt<PostStore>();
  final CameraService _cameraService = getIt<CameraService>();

  String? _imagePath;
  bool _isLoading = false;

  Future<void> _takePhoto() async {
    if (!_cameraService.isCameraAvailable()) {
      _showPlatformError();
      return;
    }

    try {
      final XFile? photo = await _cameraService.takePhoto();

      if (photo != null) {
        // Usa o método que retorna string compatível
        final imageUrl = await _cameraService.getPlatformCompatibleImage(photo);
        if (imageUrl != null) {
          setState(() {
            _imagePath = imageUrl;
          });
        }
      }
    } catch (e) {
      _showError('Erro ao acessar câmera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _cameraService.pickImageFromGallery();

      if (image != null) {
        // Usa o método que retorna string compatível
        final imageUrl = await _cameraService.getPlatformCompatibleImage(image);
        if (imageUrl != null) {
          setState(() {
            _imagePath = imageUrl;
          });
        }
      }
    } catch (e) {
      _showError('Erro ao acessar galeria: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      _showError('Por favor, escreva algo no post');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Chama o callback passando conteúdo e imagem
      widget.onPostCreated(_contentController.text.trim(), _imagePath);

      // Fecha a página/modal
      Navigator.pop(context);
    } catch (e) {
      _showError('Erro ao criar post: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPlatformError() {
    final platform = _cameraService.getPlatformInfo();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Câmera não disponível'),
        content: Text(
          'A funcionalidade de câmera não está disponível na plataforma $platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showImageFullScreen() {
    if (_imagePath == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(
          imagePath: _imagePath!,
          isNetworkImage: true, // Agora todas são "network images"
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Post'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.send),
            onPressed: _isLoading ? null : _createPost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de texto
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'O que você está pensando?',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Preview da imagem
            if (_imagePath != null) ...[
              GestureDetector(
                onTap: _showImageFullScreen,
                child: ImagePreview(
                  imagePath: _imagePath!,
                  isNetworkImage: true, // Importante para Web
                  onRemove: _removeImage,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Botões de ação
            Row(
              children: [
                // Botão da câmera
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Tirar Foto',
                    onPressed: _takePhoto,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),

                // Botão da galeria
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    onPressed: _pickFromGallery,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Informações da plataforma
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Plataforma: ${_cameraService.getPlatformInfo()}\n'
                      'Câmera disponível: ${_cameraService.isCameraAvailable() ? 'Sim' : 'Não'}\n'
                      'Modo: ${kIsWeb ? 'Web' : 'Mobile'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
