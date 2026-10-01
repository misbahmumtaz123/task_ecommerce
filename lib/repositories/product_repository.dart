import '../core/network/api_exceptions.dart';
import '../core/utils/result.dart';
import '../models/category_model.dart';
import '../models/pagination_query_model.dart';
import '../models/product_model.dart';
import '../models/product_response_model.dart';
import '../services/product_api_service.dart';

/// Contract defining data operations for Products
abstract class ProductRepository {
  Future<Result<ProductResponseModel>> getProducts({
    int limit = 30,
    int skip = 0,
    PaginationQuery? pagination,
  });
  Future<Result<ProductResponseModel>> searchProducts(String query);
  Future<Result<ProductResponseModel>> getProductsByCategory(String categorySlug);
  Future<Result<ProductModel>> getProductById(int id);
  Future<Result<List<CategoryModel>>> getCategories();
}

/// Implementation of [ProductRepository]
class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService _apiService;

  ProductRepositoryImpl({ProductApiService? apiService})
      : _apiService = apiService ?? ProductApiServiceImpl();

  @override
  Future<Result<ProductResponseModel>> getProducts({
    int limit = 30,
    int skip = 0,
    PaginationQuery? pagination,
  }) async {
    try {
      final json = await _apiService.fetchProducts(
        limit: limit,
        skip: skip,
        pagination: pagination,
      );
      final model = ProductResponseModel.fromJson(json);
      return Result.success(model);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnexpectedApiException(e.toString()));
    }
  }

  @override
  Future<Result<ProductResponseModel>> searchProducts(String query) async {
    try {
      final json = await _apiService.searchProducts(query);
      final model = ProductResponseModel.fromJson(json);
      return Result.success(model);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnexpectedApiException(e.toString()));
    }
  }

  @override
  Future<Result<ProductResponseModel>> getProductsByCategory(String categorySlug) async {
    try {
      final json = await _apiService.fetchProductsByCategory(categorySlug);
      final model = ProductResponseModel.fromJson(json);
      return Result.success(model);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnexpectedApiException(e.toString()));
    }
  }

  @override
  Future<Result<ProductModel>> getProductById(int id) async {
    try {
      final json = await _apiService.fetchProductById(id);
      final model = ProductModel.fromJson(json);
      return Result.success(model);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnexpectedApiException(e.toString()));
    }
  }

  @override
  Future<Result<List<CategoryModel>>> getCategories() async {
    try {
      final list = await _apiService.fetchCategories();
      final models = list.map((item) {
        if (item is String) {
          return CategoryModel(slug: item, name: _capitalize(item), url: '');
        } else if (item is Map<String, dynamic>) {
          return CategoryModel.fromJson(item);
        } else {
          return CategoryModel(slug: item.toString(), name: item.toString(), url: '');
        }
      }).toList();
      return Result.success(models);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnexpectedApiException(e.toString()));
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
