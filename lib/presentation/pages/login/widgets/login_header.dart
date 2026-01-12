import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/presentation/pages/login/widgets/login_controller.dart';

class LoginHeader extends StatelessWidget {
  final LoginController controller;

  const LoginHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo da empresa
        Image.asset(
          'assets/images/esig.png',
          height: 150,
          width: 320,
          fit: BoxFit.contain,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              child: child,
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
        ),
        const SizedBox(height: 30),

        // Saudação
        Observer(
          builder: (_) {
            return Text(
              controller.greeting,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            );
          },
        ),
        const SizedBox(height: 10),

        // Subtítulo
        Text(
          'Faça login para continuar',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}