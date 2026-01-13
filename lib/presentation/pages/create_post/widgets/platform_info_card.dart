import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformInfoCard extends StatelessWidget {
  final String platformInfo;
  final bool isCameraAvailable;

  const PlatformInfoCard({
    super.key,
    required this.platformInfo,
    required this.isCameraAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              'Plataforma: $platformInfo\n'
              'Câmera disponível: ${isCameraAvailable ? 'Sim' : 'Não'}\n'
              'Modo: ${kIsWeb ? 'Web' : 'Mobile'}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}