import 'package:flutter/material.dart';
import 'package:social_feed_app/core/themes/app_theme.dart';
import 'package:social_feed_app/presentation/pages/feed/feed_page.dart';
import 'package:social_feed_app/presentation/pages/login/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  String _username = '';

  void _handleLogin(String username, String password) {
    // Validação simples (depois vamos implementar melhor)
    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoggedIn = true;
        _username = username;
      });
    }
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _username = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Feed App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn
          ? FeedPage(
              username: _username,
              onLogout: _handleLogout,
            )
          : LoginPage(
              onLogin: _handleLogin,
            ),
    );
  }
}