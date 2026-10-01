import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// GetX Controller managing authentication state and actions
class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  // Reactive state
  final Rxn<UserModel> _currentUser = Rxn<UserModel>();
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _obscurePassword = true.obs;
  final RxBool _rememberMe = true.obs;

  // Getters
  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _currentUser.value != null;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get obscurePassword => _obscurePassword.value;
  bool get rememberMe => _rememberMe.value;

  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  void toggleRememberMe(bool? value) {
    _rememberMe.value = value ?? false;
  }

  void clearError() {
    _errorMessage.value = '';
  }

  /// Autofill demo credentials for testing DummyJSON authentication
  void fillDemoCredentials(TextEditingController usernameController, TextEditingController passwordController) {
    usernameController.text = 'emilys';
    passwordController.text = 'emilyspass';
    clearError();
  }

  /// Login user via DummyJSON
  Future<bool> login(String username, String password) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();
    if (cleanUsername.isEmpty || cleanPassword.isEmpty) {
      _errorMessage.value = 'Please enter both username and password';
      return false;
    }

    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await _authRepository.login(
      username: cleanUsername,
      password: cleanPassword,
    );

    _isLoading.value = false;

    return result.when(
      success: (user) {
        _currentUser.value = user;
        _errorMessage.value = '';
        return true;
      },
      failure: (exception) {
        _errorMessage.value = exception.message;
        return false;
      },
    );
  }

  /// Register new user with DummyJSON
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await _authRepository.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    _isLoading.value = false;

    return result.when(
      success: (user) {
        _currentUser.value = user;
        _errorMessage.value = '';
        return true;
      },
      failure: (exception) {
        _errorMessage.value = exception.message;
        return false;
      },
    );
  }

  /// Logout current user
  void logout() {
    _currentUser.value = null;
    _errorMessage.value = '';
  }
}
