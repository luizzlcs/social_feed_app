import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/presentation/pages/login/widgets/error_message.dart';
import 'package:social_feed_app/presentation/pages/login/widgets/login_controller.dart';
import 'package:social_feed_app/presentation/widgets/custom_button.dart';

class LoginForm extends StatelessWidget {
  final LoginController controller;

  const LoginForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildUsernameField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 16),
          ErrorMessage(authStore: controller.authStore),

          const SizedBox(height: 30),
          _buildLoginButton(context),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: controller.usernameController,
      decoration: InputDecoration(
        labelText: 'Usuário',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, digite seu usuário';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: controller.passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, digite sua senha';
        }
        if (value.length < 6) {
          return 'A senha deve ter pelo menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Observer(
      builder: (_) {
        return CustomButton(
          text: 'Entrar',
          onPressed: controller.authStore.isLoading
              ? null
              : () => controller.performLogin(context),
          isLoading: controller.authStore.isLoading,
        );
      },
    );
  }
}