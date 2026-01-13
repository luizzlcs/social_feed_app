import 'package:flutter/material.dart';
import 'package:social_feed_app/presentation/pages/create_post/controllers/create_post_controller.dart';
import 'package:social_feed_app/presentation/pages/create_post/widgets/post_content_field.dart';
import 'package:social_feed_app/presentation/pages/create_post/widgets/image_picker_buttons.dart';
import 'package:social_feed_app/presentation/pages/create_post/widgets/platform_info_card.dart';
import 'package:social_feed_app/presentation/widgets/image_preview.dart';

class CreatePostPage extends StatefulWidget {
  final Function(String, String?) onPostCreated;

  const CreatePostPage({super.key, required this.onPostCreated});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final CreatePostController _controller = CreatePostController();

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _controller.imagePathNotifier.addListener(() {
      if (mounted) setState(() {});
    });
    
    _controller.isLoadingNotifier.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _createPost() async {
    final error = _controller.validateContent(_contentController.text);
    if (error != null) {
      _showError(error);
      return;
    }

    _controller.startLoading();

    try {
      widget.onPostCreated(_contentController.text.trim(), _controller.imagePath);
      Navigator.pop(context);
    } catch (e) {
      _showError('Erro ao criar post: $e');
    } finally {
      _controller.stopLoading();
    }
  }

  void _showImageFullScreen() {
    if (_controller.imagePath == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(
          imagePath: _controller.imagePath!,
          isNetworkImage: true,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget? _buildImagePreview() {
    if (_controller.imagePath == null) return null;

    return Column(
      children: [
        GestureDetector(
          onTap: _showImageFullScreen,
          child: ImagePreview(
            imagePath: _controller.imagePath!,
            isNetworkImage: true,
            onRemove: _controller.removeImage,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Novo Post'),
      actions: [
        IconButton(
          icon: _controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          onPressed: _controller.isLoading ? null : _createPost,
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          PostContentField(controller: _contentController),
          const SizedBox(height: 16),
          // Spread operator com verificação
          if (_controller.imagePath != null) ...[
            GestureDetector(
              onTap: _showImageFullScreen,
              child: ImagePreview(
                imagePath: _controller.imagePath!,
                isNetworkImage: true,
                onRemove: _controller.removeImage,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ImagePickerButtons(
            onTakePhoto: () async {
              try {
                await _controller.takePhoto();
              } catch (e) {
                _showError(e.toString());
              }
            },
            onPickFromGallery: () async {
              try {
                await _controller.pickFromGallery();
              } catch (e) {
                _showError(e.toString());
              }
            },
            isCameraAvailable: _controller.isCameraAvailable,
          ),
          const SizedBox(height: 16),
          PlatformInfoCard(
            platformInfo: _controller.platformInfo,
            isCameraAvailable: _controller.isCameraAvailable,
          ),
        ],
      ),
    ),
  );
}

  @override
  void dispose() {
    _contentController.dispose();
    _controller.dispose();
    super.dispose();
  }
}