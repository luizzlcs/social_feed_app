import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_feed_app/domain/entities/post.dart';
import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';

class PostCardHelper {
  /// Formata data e hora
  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inHours < 1) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Há ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  /// Verifica se o post está sendo processado
  bool isPostOptimistic(String postId) {
    final postStore = getIt<PostStore>();
    return postStore.shouldShowLoading(postId);
  }

  /// Verifica se o post é do usuário atual
  bool isCurrentUserPost(Post post) {
    final authStore = getIt<AuthStore>();
    return post.userId == authStore.userId;
  }

  /// Obtém o nome de usuário para exibição
  String getDisplayUsername(Post post, bool isCurrentUserPost) {
    if (isCurrentUserPost) {
      return 'Você';
    } else if (post.username.isNotEmpty) {
      return post.username;
    } else {
      return 'Usuário';
    }
  }

  /// Obtém a primeira letra para o avatar
  String getAvatarInitial(String displayUsername) {
    if (displayUsername.isNotEmpty) {
      return displayUsername[0].toUpperCase();
    }
    return '?';
  }

  /// Obtém a cor do avatar
  Color? getAvatarColor(
    BuildContext context,
    Post post,
    bool isActuallyOptimistic,
    bool isCurrentUserPost,
  ) {
    if (isActuallyOptimistic) {
      return Colors.blue[100];
    } else if (isCurrentUserPost) {
      return Theme.of(context).primaryColor;
    } else {
      return _generateUserColor(post.userId + post.username);
    }
  }

  /// Gera cor baseada no usuário
  Color? _generateUserColor(String userIdOrUsername) {
    if (userIdOrUsername.isEmpty) return Colors.grey[400];

    final hash = userIdOrUsername.hashCode;
    final colors = [
      Colors.red[400],
      Colors.blue[400],
      Colors.green[400],
      Colors.orange[400],
      Colors.purple[400],
      Colors.teal[400],
      Colors.pink[400],
      Colors.cyan[400],
      Colors.indigo[400],
      Colors.amber[400],
    ];
    return colors[hash.abs() % colors.length];
  }

  /// Obtém a borda do card
  BorderSide getCardBorder(Post post, bool isActuallyOptimistic) {
    if (post.syncFailed) {
      return BorderSide(color: Colors.red.withOpacity(0.3));
    } else if (isActuallyOptimistic) {
      return BorderSide(color: Colors.blue.withOpacity(0.3));
    }
    return BorderSide.none; // IMPORTANTE: BorderSide.none em vez de null
  }
}
