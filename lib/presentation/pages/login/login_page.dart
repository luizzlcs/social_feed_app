// lib/presentation/pages/login/login_page.dart
import 'package:flutter/material.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/presentation/pages/login/widgets/demo_credentials.dart';
import 'package:social_feed_app/presentation/pages/login/widgets/login_controller.dart';
import 'package:social_feed_app/presentation/pages/login/widgets/login_form.dart';
import 'package:social_feed_app/presentation/pages/login/widgets/login_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = getIt<LoginController>();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cabeçalho
              LoginHeader(controller: _controller),
              const SizedBox(height: 40),

              // Formulário
              LoginForm(controller: _controller),
              const SizedBox(height: 20),

              // Botão de credenciais demo
              DemoCredentialsButton(controller: _controller),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}