import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/detail_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/onboarding_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/product_repository.dart';

/// Application Bindings class that manages controller dependencies for GetMaterialApp
class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NavigationController>()) {
      Get.put<NavigationController>(NavigationController(), permanent: true);
    }
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put<FavoritesController>(FavoritesController(), permanent: true);
    }
    if (!Get.isRegistered<OnboardingController>()) {
      Get.lazyPut<OnboardingController>(() => OnboardingController(), fenix: true);
    }
    if (!Get.isRegistered<DetailController>()) {
      if (Get.isRegistered<ProductRepository>()) {
        Get.lazyPut<DetailController>(
          () => DetailController(Get.find<ProductRepository>()),
          fenix: true,
        );
      }
    }
    if (!Get.isRegistered<AuthController>()) {
      if (Get.isRegistered<AuthRepository>()) {
        Get.lazyPut<AuthController>(
          () => AuthController(authRepository: Get.find<AuthRepository>()),
          fenix: true,
        );
      }
    }
  }
}
