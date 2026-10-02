import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/routing/app_routes.dart';
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

    // All validation conditions must be fulfilled before proceeding
    Get.snackbar(
      'Account Created! 🎉',
      'Your account has been created successfully. Please sign in.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );

    // Navigate to sign in page
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().toLogin();
    } else {
      Get.offAllNamed(AppRoutes.login);
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
