import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../controllers/favorites_controller.dart';
import '../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_badge_button.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

/// Screen displaying the user's saved favorite products
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesController = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          CartBadgeButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Obx(() {
            final items = favoritesController.favoriteProducts;

            if (items.isEmpty) {
              return EmptyView(
                icon: Icons.favorite_border_rounded,
                title: 'No Favorites Yet',
                subtitle: 'Tap the heart icon on any product to save it for later.',
                actionLabel: 'Discover Products',
                onAction: () => Navigator.of(context).pop(),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: (0.63 / MediaQuery.textScalerOf(context).scale(1.0)).clamp(0.54, 0.70),
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: product.id,
                          initialProduct: product,
                        ),
                      ),
                    );
                  },
                  onAddToCart: () {
                    context.read<CartProvider>().addItem(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.title} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
