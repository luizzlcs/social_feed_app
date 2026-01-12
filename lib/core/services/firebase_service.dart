import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:social_feed_app/core/firebase/firebase_config.dart';

class FirebaseService {
  static FirebaseService? _instance;
  
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;
  
  bool _initialized = false;

  FirebaseService._();

  factory FirebaseService() {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options:  FirebaseOptions(
            apiKey: FirebaseConfig.webConfig['apiKey']!,
            authDomain: FirebaseConfig.webConfig['authDomain']!,
            projectId: FirebaseConfig.webConfig['projectId']!,
            storageBucket: FirebaseConfig.webConfig['storageBucket']!,
            messagingSenderId: FirebaseConfig.webConfig['messagingSenderId']!,
            appId: FirebaseConfig.webConfig['appId']!,
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      
      _initialized = true;
      
      if (kDebugMode) {
        print('Firebase inicializado com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao inicializar Firebase: $e');
      }
      rethrow;
    }
  }

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  
  bool get isInitialized => _initialized;
  User? get currentUser => _auth.currentUser;
  
  CollectionReference<Map<String, dynamic>> get usersCollection => 
      _firestore.collection('users').withConverter<Map<String, dynamic>>(
        fromFirestore: (snapshot, _) => snapshot.data()!,
        toFirestore: (value, _) => value,
      );
  
  CollectionReference<Map<String, dynamic>> get postsCollection => 
      _firestore.collection('posts').withConverter<Map<String, dynamic>>(
        fromFirestore: (snapshot, _) => snapshot.data()!,
        toFirestore: (value, _) => value,
      );
  
  CollectionReference<Map<String, dynamic>> get commentsCollection => 
      _firestore.collection('comments').withConverter<Map<String, dynamic>>(
        fromFirestore: (snapshot, _) => snapshot.data()!,
        toFirestore: (value, _) => value,
      );
  
  Reference get storageRef => _storage.ref();
}