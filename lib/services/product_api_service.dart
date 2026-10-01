import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/pagination_query_model.dart';

abstract class ProductApiService {
  Future<Map<String, dynamic>> fetchProducts({
    int limit = 6,
    int skip = 0,
    PaginationQuery? pagination,
  });
  Future<Map<String, dynamic>> searchProducts(String query);
  Future<Map<String, dynamic>> fetchProductsByCategory(String categorySlug);
  Future<Map<String, dynamic>> fetchProductById(int id);
  Future<List<dynamic>> fetchCategories();
}

/// Concrete implementation of [ProductApiService] talking to DummyJSON
class ProductApiServiceImpl implements ProductApiService {
  final ApiClient _client;

  ProductApiServiceImpl({ApiClient? client}) : _client = client ?? ApiClient();

  @override
  Future<Map<String, dynamic>> fetchProducts({
    int limit = 6,
    int skip = 0,
    PaginationQuery? pagination,
  }) async {
    final effectiveLimit = pagination?.limit ?? limit;
    final effectiveSkip = pagination?.skip ?? skip;

    final response = await _client.get(
      ApiConstants.products,
      queryParameters: {'limit': effectiveLimit, 'skip': effectiveSkip},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> searchProducts(String query) async {
    final response = await _client.get(
      ApiConstants.searchProducts,
      queryParameters: {'q': query},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchProductsByCategory(
    String categorySlug,
  ) async {
    final response = await _client.get(
      '${ApiConstants.categoryProducts}/$categorySlug',
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchProductById(int id) async {
    final response = await _client.get('${ApiConstants.products}/$id');
    return response as Map<String, dynamic>;
  }

  @override
  Future<List<dynamic>> fetchCategories() async {
    final response = await _client.get(ApiConstants.categories);
    return response as List<dynamic>;
  }
}
