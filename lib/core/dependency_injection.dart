import 'package:get_it/get_it.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';

final GetIt getIt = GetIt.instance;

void setupDependencies() {
  // Registra o AuthStore como Singleton (única instância para todo o app)
  getIt.registerLazySingleton(() => AuthStore());

  // Registra o PostStore como Singleton
  getIt.registerLazySingleton(() => PostStore());
  
  
}