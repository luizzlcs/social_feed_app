import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @observable
  bool isLoggedIn = false;
  
  @observable
  String username = '';
  
  @observable
  String? userId;
  
  @observable
  String? userEmail;
  
  @observable
  bool isLoading = false;
  
  @observable
  String? errorMessage;

  @action
  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final user = userCredential.user!;
        userId = user.uid;
        username = user.displayName ?? user.email?.split('@').first ?? 'Usuário';
        userEmail = user.email;
        isLoggedIn = true;
        
        if (kDebugMode) {
          print('✅ Login Firebase: $username ($userId)');
        }
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = _handleFirebaseAuthError(e);
    } catch (e) {
      errorMessage = 'Erro ao fazer login: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> register(String email, String password, String username) async {
    isLoading = true;
    errorMessage = null;
    
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(username);
        
        userId = userCredential.user!.uid;
        this.username = username;
        userEmail = email;
        isLoggedIn = true;
        
        if (kDebugMode) {
          print('✅ Registro Firebase: $username ($userId)');
        }
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = _handleFirebaseAuthError(e);
    } catch (e) {
      errorMessage = 'Erro ao registrar: $e';
    } finally {
      isLoading = false;
    }
  }
  
  @action
  void logout() {
    _auth.signOut();
    username = '';
    userId = null;
    userEmail = null;
    isLoggedIn = false;
    errorMessage = null;
  }
  
  @action
  Future<void> checkAuthStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      username = user.displayName ?? user.email?.split('@').first ?? 'Usuário';
      userEmail = user.email;
      isLoggedIn = true;
    }
  }
  
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email inválido';
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Este email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
  
  @computed
  bool get canLogin => username.isNotEmpty;
  
  @computed
  String get greeting => isLoggedIn ? 'Olá, $username!' : 'Social Feed';
}