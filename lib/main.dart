import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/core/themes/app_theme.dart';
import 'package:social_feed_app/presentation/pages/feed/feed_page.dart';
import 'package:social_feed_app/presentation/pages/login/login_page.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart'; // ✅ Adicione este import

void main() async {
  debugPrint('🚀 Aplicação iniciando...');

  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Feed App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  late final AuthStore _authStore;
  late final PostStore _postStore;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _authStore = getIt<AuthStore>();
    _postStore = getIt<PostStore>();

    // ✅ Verifica status de autenticação ao iniciar
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Se estiver usando Firebase Auth, descomente:
    // await _authStore.checkAuthStatus();

    // Para AuthStore simples, só verifica se já está logado
    if (_authStore.isLoggedIn && _authStore.userId != null) {
      // ✅ CONFIGURAÇÃO IMPORTANTE: Passa userId para PostStore
      _postStore.setCurrentUserId(_authStore.userId!);
    }

    setState(() {
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Observer(
      builder: (_) {
        if (_authStore.isLoggedIn) {
          // ✅ CORRIGIDO: Usa getter público em vez de campo privado
          if (_authStore.userId != null && _postStore.currentUserId == null) {
            _postStore.setCurrentUserId(_authStore.userId!);
          }

          return FeedPage(username: _authStore.username);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
