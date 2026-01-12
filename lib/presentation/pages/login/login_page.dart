import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart'; // ✅ Importe o PostStore
import 'package:social_feed_app/presentation/widgets/custom_button.dart';
import 'package:social_feed_app/presentation/pages/feed/feed_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthStore _authStore;
  late final PostStore _postStore;

  @override
  void initState() {
    super.initState();
    _authStore = getIt<AuthStore>();
    _postStore = getIt<PostStore>(); // ✅ Inicializa PostStore

    // Preenche com dados demo para facilitar teste
    _usernameController.text = 'marcus@gmail.com';
    _passwordController.text = '123123';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Ícone
                Icon(
                  Icons.people,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 30),

                // Saudação
                Observer(
                  builder: (_) {
                    return Text(
                      _authStore.greeting,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Faça login para continuar',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // Formulário
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
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
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
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
                      ),

                      // Mensagem de erro
                      Observer(
                        builder: (_) {
                          if (_authStore.errorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      233,
                                      147,
                                      147,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _authStore.errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),

                      const SizedBox(height: 30),

                      // Botão de login
                      Observer(
                        builder: (_) {
                          return CustomButton(
                            text: 'Entrar',
                            onPressed: _authStore.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      await _performLogin();
                                    }
                                  },
                            isLoading: _authStore.isLoading,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Link para preencher dados demo
                      TextButton(
                        onPressed: () {
                          _usernameController.text = 'marcus@gmail.com';
                          _passwordController.text = '123123';
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Credenciais preenchidas automaticamente',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_fix_high, size: 16),
                            SizedBox(width: 8),
                            Text('Usar credenciais demo'),
                          ],
                        ),
                      ),

                      // Informação sobre o sistema de curtidas
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Sistema de Curtidas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Após o login, você poderá curtir posts e ver quais você já curtiu. '
                              'Suas curtidas serão salvas personalizadamente.',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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

  // ✅ MÉTODO SEPARADO PARA LÓGICA DE LOGIN
  Future<void> _performLogin() async {
    try {
      await _authStore.login(
        _usernameController.text,
        _passwordController.text,
      );

      // ✅ INTEGRAÇÃO CRÍTICA: Configurar PostStore após login bem-sucedido
      if (_authStore.isLoggedIn && _authStore.userId != null) {
        // 1. Configura PostStore com userId do usuário
        _postStore.setCurrentUserId(_authStore.userId!);

        if (mounted) {
          // 2. Mostra feedback visual
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bem-vindo, ${_authStore.username}!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // 3. Pequena pausa para mostrar o snackbar
          await Future.delayed(const Duration(milliseconds: 500));

          // 4. Navega para o Feed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FeedPage(username: _authStore.username),
            ),
          );
        }
      }
    } catch (e) {
      // Erro já tratado no AuthStore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro: ${_authStore.errorMessage ?? "Falha no login"}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
