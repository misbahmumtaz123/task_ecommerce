import 'package:get/get.dart';
import '../models/product_model.dart';

/// GetX controller managing user's favorite products.
/// Keeps favorites synchronized across Product List, Product Details, and Favorites screens.
class FavoritesController extends GetxController {
  // Reactive set of favorite product IDs for fast O(1) checks
  final RxSet<int> _favoriteIds = <int>{}.obs;

  // Reactive list of full product models for the favorites screen
  final RxList<ProductModel> _favoriteProducts = <ProductModel>[].obs;

  List<ProductModel> get favoriteProducts => _favoriteProducts;
  int get count => _favoriteProducts.length;

  /// Check whether a product ID is currently favorited
  bool isFavorite(int productId) {
    return _favoriteIds.contains(productId);
  }

  /// Toggle favorite state for a given product
  void toggleFavorite(ProductModel product) {
    if (_favoriteIds.contains(product.id)) {
      _favoriteIds.remove(product.id);
      _favoriteProducts.removeWhere((p) => p.id == product.id);
    } else {
      _favoriteIds.add(product.id);
      // Avoid duplicate product model instances
      if (!_favoriteProducts.any((p) => p.id == product.id)) {
        _favoriteProducts.add(product);
      }
    }
  }

  /// Explicitly remove a favorite by product ID
  void removeFavorite(int productId) {
    _favoriteIds.remove(productId);
    _favoriteProducts.removeWhere((p) => p.id == productId);
  }

  /// Clear all favorites
  void clearAll() {
    _favoriteIds.clear();
    _favoriteProducts.clear();
  }
}
