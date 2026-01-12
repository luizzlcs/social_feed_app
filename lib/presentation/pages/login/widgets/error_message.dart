// lib/presentation/pages/login/widgets/error_message.dart
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';

class ErrorMessage extends StatelessWidget {
  final AuthStore authStore;

  const ErrorMessage({super.key, required this.authStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (authStore.errorMessage == null) return const SizedBox();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(255, 233, 147, 147),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authStore.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}