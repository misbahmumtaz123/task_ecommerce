import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'navigation_controller.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  void onPageChanged(int index) {
    _currentIndex.value = index;
  }

  void nextPage(int totalPages) {
    if (_currentIndex.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  void finishOnboarding() {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().toLogin();
    } else {
      Get.put(NavigationController()).toLogin();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
