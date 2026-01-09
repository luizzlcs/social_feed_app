import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

// ignore: library_private_types_in_public_api
class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  // Observables (variáveis que serão observadas pela UI)
  @observable
  bool isLoggedIn = false;
  
  @observable
  String username = '';
  
  @observable
  bool isLoading = false;
  
  @observable
  String? errorMessage;
  
  // Actions (métodos que modificam os observables)
  @action
  Future<void> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    
    // Simula uma requisição de API
    await Future.delayed(const Duration(seconds: 1));
    
    // Validação simples (depois vamos melhorar)
    if (username.isEmpty || password.isEmpty) {
      errorMessage = 'Usuário e senha são obrigatórios';
      isLoading = false;
      return;
    }
    
    if (password.length < 6) {
      errorMessage = 'Senha deve ter pelo menos 6 caracteres';
      isLoading = false;
      return;
    }
    
    // Se tudo OK, faz login
    this.username = username;
    isLoggedIn = true;
    isLoading = false;
  }
  
  @action
  void logout() {
    username = '';
    isLoggedIn = false;
    errorMessage = null;
  }
  
  // Computed (valores calculados a partir de observables)
  @computed
  bool get canLogin => username.isNotEmpty;
  
  @computed
  String get greeting => isLoggedIn ? 'Olá, $username!' : 'Faça login';
}