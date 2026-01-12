// lib/presentation/pages/login/widgets/demo_credentials.dart
import 'package:flutter/material.dart';
import 'package:social_feed_app/presentation/pages/login/widgets/login_controller.dart';

class DemoCredentialsButton extends StatelessWidget {
  final LoginController controller;

  const DemoCredentialsButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => controller.fillDemoCredentials(context),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_fix_high, size: 16),
          SizedBox(width: 8),
          Text('Usar credenciais demo'),
        ],
      ),
    );
  }
}