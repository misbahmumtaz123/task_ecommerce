import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import 'auth_controller.dart';
import 'navigation_controller.dart';

/// Controller managing Login form state and authentication operations
class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool isPasswordObscured = true.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void setDemoCredentials(String username, String password) {
    usernameController.text = username;
    passwordController.text = password;
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    final authController = Get.find<AuthController>();
    final success = await authController.login(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );

    if (success) {
      Get.snackbar(
        'Welcome, ${authController.currentUser?.firstName ?? 'Shopper'}! 🎉',
        'Signed in successfully with DummyJSON.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().toProducts();
      }
    } else {
      Get.snackbar(
        'Sign In Failed',
        authController.errorMessage.isNotEmpty
            ? authController.errorMessage
            : 'Unable to sign in. Please check your credentials.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    }
  }

  void continueAsGuest() {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().toProducts();
    }
  }

  void goToRegister() {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().toRegister();
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
