import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/controllers/detail_controller.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/core/network/api_exceptions.dart';
import 'package:ecommerce_app/core/utils/result.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/pagination_query_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/product_response_model.dart';
import 'package:ecommerce_app/repositories/product_repository.dart';

class FakeProductRepository implements ProductRepository {
  final ProductModel? returnProduct;
  final bool shouldFail;

  FakeProductRepository({this.returnProduct, this.shouldFail = false});

  @override
  Future<Result<ProductModel>> getProductById(int id) async {
    if (shouldFail) {
      return Result.failure(const NotFoundException('Product not found', 404));
    }
    return Result.success(
      returnProduct ??
          ProductModel(
            id: id,
            title: 'Sample Product $id',
            description: 'Sample description for $id',
            category: 'electronics',
            price: 99.99,
            thumbnail: 'https://example.com/thumb.jpg',
            images: const ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
          ),
    );
  }

  @override
  Future<Result<ProductResponseModel>> getProducts({int limit = 30, int skip = 0, PaginationQuery? pagination}) async {
    return Result.success(const ProductResponseModel(products: [], total: 0, skip: 0, limit: 30));
  }

  @override
  Future<Result<ProductResponseModel>> searchProducts(String query) async {
    return Result.success(const ProductResponseModel(products: [], total: 0, skip: 0, limit: 30));
  }

  @override
  Future<Result<ProductResponseModel>> getProductsByCategory(String categorySlug) async {
    return Result.success(const ProductResponseModel(products: [], total: 0, skip: 0, limit: 30));
  }

  @override
  Future<Result<List<CategoryModel>>> getCategories() async {
    return Result.success([]);
  }
}

void main() {
  group('DetailController Unit Tests', () {
    late DetailController detailController;
    const testProduct = ProductModel(
      id: 42,
      title: 'Awesome Headphones',
      description: 'Noise cancelling studio headphones',
      category: 'audio',
      price: 199.99,
      thumbnail: 'https://example.com/headphones.jpg',
      images: ['https://example.com/h1.jpg', 'https://example.com/h2.jpg'],
    );

    setUp(() {
      Get.reset();
      Get.put<FavoritesController>(FavoritesController());
      detailController = DetailController(FakeProductRepository(returnProduct: testProduct));
    });

    test('Initial controller state has no product and not loading', () {
      expect(detailController.product, isNull);
      expect(detailController.isLoading, isFalse);
      expect(detailController.errorMessage, isEmpty);
      expect(detailController.selectedImageIndex, 0);
    });

    test('setProduct populates product instantly without loading delay', () {
      detailController.setProduct(testProduct);

      expect(detailController.product, isNotNull);
      expect(detailController.product?.id, 42);
      expect(detailController.product?.title, 'Awesome Headphones');
      expect(detailController.isLoading, isFalse);
      expect(detailController.errorMessage, isEmpty);
    });

    test('fetchProduct with fallbackProduct shows data instantly while fetching', () async {
      await detailController.fetchProduct(42, fallbackProduct: testProduct);

      expect(detailController.product, isNotNull);
      expect(detailController.product?.id, 42);
      expect(detailController.isLoading, isFalse);
      expect(detailController.errorMessage, isEmpty);
    });

    test('fetchProduct without fallback fetches from repository successfully', () async {
      await detailController.fetchProduct(42);

      expect(detailController.product, isNotNull);
      expect(detailController.product?.id, 42);
      expect(detailController.product?.title, 'Awesome Headphones');
      expect(detailController.isLoading, isFalse);
      expect(detailController.errorMessage, isEmpty);
    });

    test('fetchProduct failure with no fallback records error message', () async {
      final failingController = DetailController(FakeProductRepository(shouldFail: true));
      await failingController.fetchProduct(999);

      expect(failingController.product, isNull);
      expect(failingController.isLoading, isFalse);
      expect(failingController.errorMessage, 'Product not found');
    });

    test('toggleFavorite adds and removes product from FavoritesController', () {
      detailController.setProduct(testProduct);
      final favoritesController = Get.find<FavoritesController>();

      expect(favoritesController.isFavorite(42), isFalse);

      detailController.toggleFavorite();
      expect(favoritesController.isFavorite(42), isTrue);

      detailController.toggleFavorite();
      expect(favoritesController.isFavorite(42), isFalse);
    });

    test('setSelectedImageIndex updates selected index reactively', () {
      expect(detailController.selectedImageIndex, 0);
      detailController.setSelectedImageIndex(2);
      expect(detailController.selectedImageIndex, 2);
    });
  });
}
