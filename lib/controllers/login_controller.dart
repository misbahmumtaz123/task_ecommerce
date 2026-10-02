import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/routing/app_routes.dart';
import 'auth_controller.dart';
import 'navigation_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  TextEditingController get usernameController => emailController;
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool isPasswordObscured = true.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void setCredentials(String email, String password) {
    emailController.text = email;
    passwordController.text = password;
  }

  void setDemoCredentials(String usernameOrEmail, String password) {
    emailController.text = usernameOrEmail;
    passwordController.text = password;
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    final authController = Get.find<AuthController>();
    authController.loginWithCredentials(email: email, password: password);

    Get.snackbar(
      'Welcome, ${authController.currentUser?.firstName ?? 'Shopper'}! 🎉',
      'Signed in successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );

    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().toProducts();
    } else {
      Get.offAllNamed(AppRoutes.products);
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
