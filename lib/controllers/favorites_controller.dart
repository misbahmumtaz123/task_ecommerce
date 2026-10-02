import 'package:get/get.dart';
import '../models/product_model.dart';

class FavoritesController extends GetxController {
  final RxSet<int> _favoriteIds = <int>{}.obs;

  final RxList<ProductModel> _favoriteProducts = <ProductModel>[].obs;
  List<ProductModel> get favoriteProducts => _favoriteProducts;
  int get count => _favoriteProducts.length;
  bool isFavorite(int productId) {
    return _favoriteIds.contains(productId);
  }

  void toggleFavorite(ProductModel product) {
    if (_favoriteIds.contains(product.id)) {
      _favoriteIds.remove(product.id);
      _favoriteProducts.removeWhere((p) => p.id == product.id);
    } else {
      _favoriteIds.add(product.id);

      if (!_favoriteProducts.any((p) => p.id == product.id)) {
        _favoriteProducts.add(product);
      }
    }
  }

  void removeFavorite(int productId) {
    _favoriteIds.remove(productId);
    _favoriteProducts.removeWhere((p) => p.id == productId);
  }

  void clearAll() {
    _favoriteIds.clear();
    _favoriteProducts.clear();
  }
}
