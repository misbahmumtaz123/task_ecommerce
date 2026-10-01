import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/core/utils/result.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/product_response_model.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/repositories/product_repository.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';

// ---------------------------------------------------------------------------
// Mock repository — returns predefined product for any ID
// ---------------------------------------------------------------------------
class _MockProductRepo implements ProductRepository {
  final ProductModel product;
  _MockProductRepo(this.product);

  @override
  Future<Result<List<CategoryModel>>> getCategories() async =>
      Result.success([]);

  @override
  Future<Result<ProductModel>> getProductById(int id) async =>
      Result.success(product);

  @override
  Future<Result<ProductResponseModel>> getProducts(
          {int limit = 30, int skip = 0}) async =>
      Result.success(ProductResponseModel(
          products: [product], total: 1, skip: 0, limit: 1));

  @override
  Future<Result<ProductResponseModel>> getProductsByCategory(
          String categorySlug) async =>
      Result.success(ProductResponseModel(
          products: [product], total: 1, skip: 0, limit: 1));

  @override
  Future<Result<ProductResponseModel>> searchProducts(String query) async =>
      Result.success(ProductResponseModel(
          products: [product], total: 1, skip: 0, limit: 1));
}

// ---------------------------------------------------------------------------
// Helper: wraps screen in required providers
// ---------------------------------------------------------------------------
Widget _buildApp(ProductModel product, {ProductModel? initialProduct}) {
  Get.put<FavoritesController>(FavoritesController());
  return MultiProvider(
    providers: [
      Provider<ProductRepository>.value(value: _MockProductRepo(product)),
      ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
    ],
    child: GetMaterialApp(
      home: ProductDetailScreen(
        productId: product.id,
        initialProduct: initialProduct,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Shared test fixture
// ---------------------------------------------------------------------------
const _testProduct = ProductModel(
  id: 1,
  title: 'Essence Mascara Lash Princess',
  description: 'The Essence Mascara Lash Princess is a popular mascara.',
  category: 'beauty',
  price: 9.99,
  discountPercentage: 10.5,
  rating: 4.5,
  stock: 50,
  brand: 'Essence',
  thumbnail:
      'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp',
  images: [
    'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/1.webp',
  ],
  warrantyInformation: '1 week warranty',
  shippingInformation: 'Ships in 3-5 business days',
  availabilityStatus: 'In Stock',
  returnPolicy: '30 days return',
  sku: 'BEA-001',
  minimumOrderQuantity: 2,
  reviews: [
    ProductReviewModel(
      rating: 5,
      comment: 'Great quality mascara!',
      date: '2025-01-01',
      reviewerName: 'Alice',
      reviewerEmail: 'alice@example.com',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  setUp(() => Get.reset());

  testWidgets(
      'Renders title, description, about section and reviews with initialProduct',
      (tester) async {
    await tester.pumpWidget(
        _buildApp(_testProduct, initialProduct: _testProduct));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Essence Mascara Lash Princess'), findsWidgets);
    expect(find.text('About the Product'), findsOneWidget);
    expect(find.text('Great quality mascara!'), findsOneWidget);
    expect(find.textContaining('Add to Cart'), findsOneWidget);
    expect(find.text('Product Specifications'), findsOneWidget);
  });

  testWidgets(
      'Loads and renders product details from repository when initialProduct is null',
      (tester) async {
    await tester
        .pumpWidget(_buildApp(_testProduct, initialProduct: null));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Essence Mascara Lash Princess'), findsWidgets);
    expect(find.text('About the Product'), findsOneWidget);
    expect(find.text('Great quality mascara!'), findsOneWidget);
  });

  testWidgets('Shows stock status, shipping and warranty specs', (tester) async {
    await tester.pumpWidget(
        _buildApp(_testProduct, initialProduct: _testProduct));
    await tester.pumpAndSettle();

    expect(find.textContaining('In Stock'), findsWidgets);
    expect(find.textContaining('Ships in'), findsOneWidget);
    expect(find.textContaining('warranty'), findsOneWidget);
  });

  testWidgets('Gallery shows image count indicator when product has images',
      (tester) async {
    const multiImageProduct = ProductModel(
      id: 2,
      title: 'Multi Image Product',
      description: 'A product with multiple images.',
      category: 'electronics',
      price: 49.99,
      stock: 10,
      thumbnail: 'https://dummyjson.com/image/1.jpg',
      images: [
        'https://dummyjson.com/image/1.jpg',
        'https://dummyjson.com/image/2.jpg',
        'https://dummyjson.com/image/3.jpg',
      ],
    );

    Get.reset();
    await tester.pumpWidget(
        _buildApp(multiImageProduct, initialProduct: multiImageProduct));
    await tester.pumpAndSettle();

    // With 3 images, expects "1 / 3" counter pill
    expect(find.text('1 / 3'), findsOneWidget);
  });
}
