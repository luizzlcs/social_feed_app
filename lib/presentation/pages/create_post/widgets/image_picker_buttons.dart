import 'package:flutter/material.dart';

class ImagePickerButtons extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;
  final bool isCameraAvailable;

  const ImagePickerButtons({
    super.key,
    required this.onTakePhoto,
    required this.onPickFromGallery,
    required this.isCameraAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.camera_alt,
            label: 'Tirar Foto',
            onPressed: isCameraAvailable ? onTakePhoto : null,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.photo_library,
            label: 'Galeria',
            onPressed: onPickFromGallery,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
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
}