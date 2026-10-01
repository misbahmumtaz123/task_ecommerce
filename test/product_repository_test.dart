import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/repositories/product_repository.dart';
import 'package:ecommerce_app/services/product_api_service.dart';

class FakeProductApiService implements ProductApiService {
  @override
  Future<Map<String, dynamic>> fetchProducts({int limit = 30, int skip = 0}) async {
    return {
      'products': [
        {
          'id': 1,
          'title': 'iPhone 9',
          'description': 'An apple mobile which is nothing like apple',
          'category': 'smartphones',
          'price': 549.0,
          'discountPercentage': 12.96,
          'rating': 4.69,
          'stock': 94,
          'brand': 'Apple',
          'thumbnail': 'https://i.dummyjson.com/data/products/1/thumbnail.jpg',
          'images': [
            'https://i.dummyjson.com/data/products/1/1.jpg',
          ],
        }
      ],
      'total': 100,
      'skip': 0,
      'limit': 1,
    };
  }

  @override
  Future<Map<String, dynamic>> searchProducts(String query) async {
    return {
      'products': [],
      'total': 0,
      'skip': 0,
      'limit': 30,
    };
  }

  @override
  Future<Map<String, dynamic>> fetchProductsByCategory(String categorySlug) async {
    return {
      'products': [],
      'total': 0,
      'skip': 0,
      'limit': 30,
    };
  }

  @override
  Future<Map<String, dynamic>> fetchProductById(int id) async {
    return {
      'id': id,
      'title': 'Test Item',
      'description': 'Sample description',
      'category': 'beauty',
      'price': 99.0,
      'discountPercentage': 5.0,
      'rating': 4.0,
      'stock': 10,
      'thumbnail': 'https://dummyjson.com/thumb.jpg',
      'images': [],
    };
  }

  @override
  Future<List<dynamic>> fetchCategories() async {
    return [
      {'slug': 'beauty', 'name': 'Beauty', 'url': 'https://dummyjson.com/products/category/beauty'},
      {'slug': 'fragrances', 'name': 'Fragrances', 'url': 'https://dummyjson.com/products/category/fragrances'},
    ];
  }
}

void main() {
  group('ProductRepository Unit Tests', () {
    late ProductRepository repository;

    setUp(() {
      repository = ProductRepositoryImpl(apiService: FakeProductApiService());
    });

    test('getProducts parses JSON correctly into ProductResponseModel', () async {
      final result = await repository.getProducts(limit: 1, skip: 0);

      expect(result.isSuccess, isTrue);
      result.when(
        success: (response) {
          expect(response.total, 100);
          expect(response.products.length, 1);
          final first = response.products.first;
          expect(first.id, 1);
          expect(first.title, 'iPhone 9');
          expect(first.price, 549.0);
          expect(first.rating, 4.69);
          expect(first.stock, 94);
          expect(first.brand, 'Apple');
        },
        failure: (e) => fail('Should not fail with fake service'),
      );
    });

    test('getProductById parses single ProductModel accurately', () async {
      final result = await repository.getProductById(42);

      expect(result.isSuccess, isTrue);
      result.when(
        success: (product) {
          expect(product.id, 42);
          expect(product.title, 'Test Item');
          expect(product.category, 'beauty');
        },
        failure: (e) => fail('Should not fail'),
      );
    });

    test('getCategories parses category list correctly', () async {
      final result = await repository.getCategories();

      expect(result.isSuccess, isTrue);
      result.when(
        success: (categories) {
          expect(categories.length, 2);
          expect(categories[0].slug, 'beauty');
          expect(categories[1].name, 'Fragrances');
        },
        failure: (e) => fail('Should not fail'),
      );
    });
  });
}
