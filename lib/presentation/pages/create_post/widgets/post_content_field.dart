import 'package:flutter/material.dart';

class PostContentField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const PostContentField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 8,
      decoration: const InputDecoration(
        hintText: 'O que você está pensando?',
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}