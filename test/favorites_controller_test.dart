import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/models/product_model.dart';

void main() {
  group('FavoritesController (GetX) Unit Tests', () {
    late FavoritesController controller;

    setUp(() {
      controller = FavoritesController();
    });

    test('Initial favorites list should be empty', () {
      expect(controller.favoriteProducts, isEmpty);
      expect(controller.count, 0);
      expect(controller.isFavorite(1), isFalse);
    });

    test('Toggle favorite adds and removes product properly', () {
      const product = ProductModel(
        id: 1,
        title: 'iPhone 9',
        description: 'An apple mobile which is nothing like apple',
        category: 'smartphones',
        price: 549,
        thumbnail: 'https://i.dummyjson.com/data/products/1/thumbnail.jpg',
      );

      // Add to favorites
      controller.toggleFavorite(product);
      expect(controller.isFavorite(1), isTrue);
      expect(controller.count, 1);
      expect(controller.favoriteProducts.first.title, 'iPhone 9');

      // Toggle again to remove
      controller.toggleFavorite(product);
      expect(controller.isFavorite(1), isFalse);
      expect(controller.count, 0);
      expect(controller.favoriteProducts, isEmpty);
    });

    test('Remove favorite by ID works as expected', () {
      const product1 = ProductModel(
        id: 1,
        title: 'Product 1',
        description: '',
        category: 'category',
        price: 10,
        thumbnail: '',
      );
      const product2 = ProductModel(
        id: 2,
        title: 'Product 2',
        description: '',
        category: 'category',
        price: 20,
        thumbnail: '',
      );

      controller.toggleFavorite(product1);
      controller.toggleFavorite(product2);
      expect(controller.count, 2);

      controller.removeFavorite(1);
      expect(controller.count, 1);
      expect(controller.isFavorite(1), isFalse);
      expect(controller.isFavorite(2), isTrue);
    });
  });
}
