import '../core/network/api_exceptions.dart';
import '../core/utils/result.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/product_response_model.dart';
import '../services/product_api_service.dart';

/// Contract defining data operations for Products
abstract class ProductRepository {
  Future<Result<ProductResponseModel>> getProducts({int limit = 30, int skip = 0});
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
  }) async {
    try {
      final json = await _apiService.fetchProducts(limit: limit, skip: skip);
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
      final rawList = await _apiService.fetchCategories();
      final categories = rawList.map((item) => CategoryModel.fromJson(item)).toList();
      return Result.success(categories);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnexpectedApiException(e.toString()));
    }
  }
}
