// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStoreBase, Store {
  Computed<bool>? _$canLoginComputed;

  @override
  bool get canLogin => (_$canLoginComputed ??= Computed<bool>(
    () => super.canLogin,
    name: '_AuthStoreBase.canLogin',
  )).value;
  Computed<String>? _$greetingComputed;

  @override
  String get greeting => (_$greetingComputed ??= Computed<String>(
    () => super.greeting,
    name: '_AuthStoreBase.greeting',
  )).value;

  late final _$isLoggedInAtom = Atom(
    name: '_AuthStoreBase.isLoggedIn',
    context: context,
  );

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$usernameAtom = Atom(
    name: '_AuthStoreBase.username',
    context: context,
  );

  @override
  String get username {
    _$usernameAtom.reportRead();
    return super.username;
  }

  @override
  set username(String value) {
    _$usernameAtom.reportWrite(value, super.username, () {
      super.username = value;
    });
  }

  late final _$userIdAtom = Atom(
    name: '_AuthStoreBase.userId',
    context: context,
  );

  @override
  String? get userId {
    _$userIdAtom.reportRead();
    return super.userId;
  }

  @override
  set userId(String? value) {
    _$userIdAtom.reportWrite(value, super.userId, () {
      super.userId = value;
    });
  }

  late final _$userEmailAtom = Atom(
    name: '_AuthStoreBase.userEmail',
    context: context,
  );

  @override
  String? get userEmail {
    _$userEmailAtom.reportRead();
    return super.userEmail;
  }

  @override
  set userEmail(String? value) {
    _$userEmailAtom.reportWrite(value, super.userEmail, () {
      super.userEmail = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_AuthStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_AuthStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$loginAsyncAction = AsyncAction(
    '_AuthStoreBase.login',
    context: context,
  );

  @override
  Future<void> login(String email, String password) {
    return _$loginAsyncAction.run(() => super.login(email, password));
  }

  late final _$registerAsyncAction = AsyncAction(
    '_AuthStoreBase.register',
    context: context,
  );

  @override
  Future<void> register(String email, String password, String username) {
    return _$registerAsyncAction.run(
      () => super.register(email, password, username),
    );
  }

  late final _$checkAuthStatusAsyncAction = AsyncAction(
    '_AuthStoreBase.checkAuthStatus',
    context: context,
  );

  @override
  Future<void> checkAuthStatus() {
    return _$checkAuthStatusAsyncAction.run(() => super.checkAuthStatus());
  }

  late final _$_AuthStoreBaseActionController = ActionController(
    name: '_AuthStoreBase',
    context: context,
  );

  @override
  void logout() {
    final _$actionInfo = _$_AuthStoreBaseActionController.startAction(
      name: '_AuthStoreBase.logout',
    );
    try {
      return super.logout();
    } finally {
      _$_AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoggedIn: ${isLoggedIn},
username: ${username},
userId: ${userId},
userEmail: ${userEmail},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
canLogin: ${canLogin},
greeting: ${greeting}
    ''';
  }
}
