// lib/presentation/pages/login/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/presentation/pages/feed/feed_page.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';

class LoginController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginController() {
    // Preenche com dados demo para facilitar teste
    // usernameController.text = 'marcus@gmail.com';
    // passwordController.text = '123123';
  }

  // ✅ Use getIt para acessar as stores
  AuthStore get authStore => getIt<AuthStore>();
  PostStore get postStore => getIt<PostStore>();

  String get greeting => authStore.greeting;

  Future<void> performLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      await authStore.login(
        usernameController.text,
        passwordController.text,
      );

      if (authStore.isLoggedIn && authStore.userId != null) {
        postStore.setCurrentUserId(authStore.userId!);

        if (context.mounted) {
          _showSuccessSnackbar(context);
          await Future.delayed(const Duration(milliseconds: 500));
          _navigateToFeed(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context);
      }
    }
  }

  void fillDemoCredentials(BuildContext context) {
    usernameController.text = 'marcus@gmail.com';
    passwordController.text = '123123';
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciais preenchidas automaticamente'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }

  // Métodos privados
  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bem-vindo, ${authStore.username}!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erro: ${authStore.errorMessage ?? "Falha no login"}',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToFeed(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FeedPage(username: authStore.username),
      ),
    );
  }
}