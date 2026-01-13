// Dependências

import 'package:social_feed_app/core/dependency_injection.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/data/repository/firebase_post_repository.dart';

class PostStoreDependencies {
  final FirebasePostRepository repository;
  final FirebaseService firebaseService;

  PostStoreDependencies()
      : repository = FirebasePostRepository(getIt<FirebaseService>()),
        firebaseService = getIt<FirebaseService>();

  factory PostStoreDependencies.create() => PostStoreDependencies();
}