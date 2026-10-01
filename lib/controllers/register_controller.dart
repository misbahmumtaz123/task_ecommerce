import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import 'auth_controller.dart';
import 'navigation_controller.dart';

/// Controller managing registration form state and submission
class RegisterController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool agreeTerms = true.obs;
  final RxBool isPasswordObscured = true.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void toggleAgreeTerms(bool? value) {
    agreeTerms.value = value ?? false;
  }

  Future<void> handleRegister() async {
    if (!formKey.currentState!.validate()) return;

    if (!agreeTerms.value) {
      Get.snackbar(
        'Terms Required',
        'Please accept the Terms & Conditions to proceed.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final authController = Get.find<AuthController>();
    final success = await authController.register(
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
    );

    if (success) {
      Get.snackbar(
        'Account Created! 🎉',
        'Welcome to AuraStore, ${firstNameController.text.trim()}!',
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
        'Registration Failed',
        authController.errorMessage.isNotEmpty
            ? authController.errorMessage
            : 'Unable to register. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    }
  }

  void backToLogin() {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().back();
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
