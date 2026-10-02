import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider({required ProductRepository repository})
    : _repository = repository;
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategorySlug;
  String _searchQuery = '';
  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategorySlug => _selectedCategorySlug;
  String get searchQuery => _searchQuery;
  bool get hasError => _errorMessage != null;
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    await Future.wait([_fetchCategoriesInternal(), _fetchProductsInternal()]);

    _setLoading(false);
  }

  Future<void> refresh() async {
    if (_searchQuery.isNotEmpty) {
      await searchProducts(_searchQuery);
    } else if (_selectedCategorySlug != null) {
      await selectCategory(_selectedCategorySlug);
    } else {
      await fetchAllProducts();
    }
  }

  Future<void> fetchAllProducts() async {
    _selectedCategorySlug = null;
    _searchQuery = '';
    _setLoading(true);
    _clearError();

    await _fetchProductsInternal();
    _setLoading(false);
  }

  Future<void> selectCategory(String? slug) async {
    if (_selectedCategorySlug == slug) return;

    _selectedCategorySlug = slug;
    _searchQuery = '';
    _setLoading(true);
    _clearError();

    if (slug == null || slug.isEmpty) {
      await _fetchProductsInternal();
    } else {
      final result = await _repository.getProductsByCategory(slug);
      result.when(
        success: (response) {
          _products = response.products;
        },
        failure: (exception) {
          _errorMessage = exception.message;
          _products = [];
        },
      );
    }

    _setLoading(false);
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query.trim();
    _selectedCategorySlug = null;
    _setLoading(true);
    _clearError();

    if (_searchQuery.isEmpty) {
      await _fetchProductsInternal();
    } else {
      final result = await _repository.searchProducts(_searchQuery);
      result.when(
        success: (response) {
          _products = response.products;
        },
        failure: (exception) {
          _errorMessage = exception.message;
          _products = [];
        },
      );
    }

    _setLoading(false);
  }

  // Internal helpers
  Future<void> _fetchProductsInternal() async {
    final result = await _repository.getProducts(limit: 50);
    result.when(
      success: (response) {
        _products = response.products;
      },
      failure: (exception) {
        _errorMessage = exception.message;
        _products = [];
      },
    );
  }

  Future<void> _fetchCategoriesInternal() async {
    final result = await _repository.getCategories();
    result.when(
      success: (data) {
        _categories = data;
      },
      failure: (exception) {},
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
