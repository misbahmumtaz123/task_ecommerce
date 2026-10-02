import '../core/network/api_exceptions.dart';
import '../core/utils/result.dart';
import '../models/category_model.dart';
import '../models/pagination_query_model.dart';
import '../models/product_model.dart';
import '../models/product_response_model.dart';
import '../services/product_api_service.dart';

abstract class ProductRepository {
  Future<Result<ProductResponseModel>> getProducts({
    int limit = 6,
    int skip = 0,
    PaginationQuery? pagination,
  });
  Future<Result<ProductResponseModel>> searchProducts(String query);
  Future<Result<ProductResponseModel>> getProductsByCategory(
    String categorySlug,
  );
  Future<Result<ProductModel>> getProductById(int id);
  Future<Result<List<CategoryModel>>> getCategories();
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService _apiService;
  List<ProductModel>? _allProductsCache;

  ProductRepositoryImpl({ProductApiService? apiService})
    : _apiService = apiService ?? ProductApiServiceImpl();

  @override
  Future<Result<ProductResponseModel>> getProducts({
    int limit = 6,
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
      if (limit == 0 || model.products.length == model.total) {
        _allProductsCache = model.products;
      }
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
      final clean = query.trim();
      if (clean.isEmpty) {
        return getProducts();
      }
      Map<String, dynamic>? searchJson;
      try {
        searchJson = await _apiService.searchProducts(clean);
      } catch (_) {}

      final searchResults = searchJson != null
          ? ProductResponseModel.fromJson(searchJson).products
          : <ProductModel>[];
      if (_allProductsCache == null) {
        try {
          final allJson = await _apiService.fetchProducts(limit: 0);
          _allProductsCache = ProductResponseModel.fromJson(allJson).products;
        } catch (_) {}
      }
      if (_allProductsCache == null || _allProductsCache!.isEmpty) {
        return Result.success(
          ProductResponseModel(
            products: searchResults,
            total: searchResults.length,
            skip: 0,
            limit: searchResults.length,
          ),
        );
      }
      final cleanLower = clean.toLowerCase();
      final normalizedQuery = cleanLower.replaceAll(RegExp(r'[\s-_]+'), ' ');

      bool matches(String? text) {
        if (text == null || text.isEmpty) return false;
        final tLower = text.toLowerCase();
        if (tLower.contains(cleanLower)) return true;
        final tNormalized = tLower.replaceAll(RegExp(r'[\s-_]+'), ' ');
        return tNormalized.contains(normalizedQuery);
      }

      final matchedIds = <int>{for (final p in searchResults) p.id};
      final combined = List<ProductModel>.from(searchResults);

      for (final p in _allProductsCache!) {
        if (matchedIds.contains(p.id)) continue;

        final brandMatch = matches(p.brand);
        final categoryMatch = matches(p.category);
        final tagMatch = p.tags.any((t) => matches(t));
        final titleMatch = matches(p.title);
        final descMatch = matches(p.description);

        if (brandMatch ||
            categoryMatch ||
            tagMatch ||
            titleMatch ||
            descMatch) {
          combined.add(p);
          matchedIds.add(p.id);
        }
      }

      return Result.success(
        ProductResponseModel(
          products: combined,
          total: combined.length,
          skip: 0,
          limit: combined.length,
        ),
      );
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnexpectedApiException(e.toString()));
    }
  }

  @override
  Future<Result<ProductResponseModel>> getProductsByCategory(
    String categorySlug,
  ) async {
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
          return CategoryModel(
            slug: item.toString(),
            name: item.toString(),
            url: '',
          );
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
