import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/routing/app_routes.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import 'detail_controller.dart';
import '../screens/cart_screen.dart';
import '../screens/product_detail_screen.dart';

/// Central Routing & Navigation Controller that encapsulates all screen transitions.
/// Decouples UI screens from direct routing logic.
class NavigationController extends GetxController {
  static NavigationController get to => Get.find<NavigationController>();

  void toOnboarding() {
    Get.offAllNamed(AppRoutes.onboarding);
  }

  void toLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  void toLoginModal() {
    Get.toNamed(AppRoutes.login);
  }

  void toRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void toProducts() {
    Get.offAllNamed(AppRoutes.products);
  }

  void toProductDetail(int productId, {ProductModel? initialProduct}) {
    final detailCtrl = Get.isRegistered<DetailController>()
        ? Get.find<DetailController>()
        : Get.put(DetailController(Get.isRegistered<ProductRepository>()
            ? Get.find<ProductRepository>()
            : ProductRepositoryImpl()));
    detailCtrl.prepareForProduct(productId, initialProduct: initialProduct);
    detailCtrl.fetchProduct(productId, fallbackProduct: initialProduct);

    Get.to(
      () => ProductDetailScreen(
        productId: productId,
        initialProduct: initialProduct,
      ),
      transition: Transition.rightToLeft,
      routeName: '${AppRoutes.productDetail}/$productId',
    );
  }

  void toCart(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void toFavorites() {
    Get.toNamed(AppRoutes.favorites);
  }

  void back() {
    Get.back();
  }
}
