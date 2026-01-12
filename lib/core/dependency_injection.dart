import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:social_feed_app/core/services/camera_service.dart';
import 'package:social_feed_app/core/services/firebase_service.dart';
import 'package:social_feed_app/presentation/stores/auth_store.dart';
import 'package:social_feed_app/presentation/stores/post_store.dart';

final GetIt getIt = GetIt.instance;

// dependency_injection.dart
bool _dependenciesInitialized = false;

Future<void> setupDependencies() async {
  if (_dependenciesInitialized) {
    debugPrint('⚠️ setupDependencies já foi chamado. Retornando...');
    return;
  }
  
  debugPrint('🔄 Inicializando dependências pela PRIMEIRA vez...');
  
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  getIt.registerSingleton<FirebaseService>(firebaseService);
  
  getIt.registerSingleton<AuthStore>(AuthStore());
  debugPrint('✅ AuthStore criado. Hash: ${getIt<AuthStore>().hashCode}');
  
  getIt.registerSingleton<PostStore>(PostStore());
  getIt.registerSingleton<CameraService>(CameraService());
  
  _dependenciesInitialized = true;
  debugPrint('🎉 Dependências inicializadas com sucesso!');
}