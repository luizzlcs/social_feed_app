import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/core/themes/app_theme.dart';
import 'package:social_feed_app/presentation/pages/feed/feed_page.dart';
import 'package:social_feed_app/presentation/pages/login/login_page.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';

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

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    
    final authStore = getIt<AuthStore>();

    return Observer(
      builder: (_) {
        if (authStore.isLoggedIn) {
          return FeedPage(username: authStore.username);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
