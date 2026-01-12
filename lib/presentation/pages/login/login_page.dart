import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';
import 'package:social_feed_app/presentation/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  
  @override
  Widget build(BuildContext context) {

    final authStore = getIt<AuthStore>();
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 100),
                const SizedBox(height: 30),
                
                Observer(
                  builder: (_) {
                    return Text(
                      authStore.greeting,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Faça login para continuar',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Usuário',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite seu usuário';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock),
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
                      ),
                      
                   
                      Observer(
                        builder: (_) {
                          if (authStore.errorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                authStore.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      Observer(
                        builder: (_) {
                          return CustomButton(
                            text: 'Entrar',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await authStore.login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                              }
                            },
                            isLoading: authStore.isLoading,
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          _usernameController.text = 'demo';
                          _passwordController.text = '123456';
                        },
                        child: const Text('Usar credenciais demo'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}