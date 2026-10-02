import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/result.dart';
import '../models/pagination_query_model.dart';
import '../models/product_response_model.dart';
import '../repositories/product_repository.dart';
import 'category_list_provider.dart';
import 'product_list_state.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  throw UnimplementedError(
    'productRepositoryProvider must be overridden in ProviderScope',
  );
});
final productListNotifierProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
      final repository = ref.watch(productRepositoryProvider);
      return ProductListNotifier(repository, ref);
    });

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository _repository;
  final Ref _ref;

  ProductListNotifier(this._repository, this._ref)
    : super(const ProductListState()) {
    initialize();
  }
  Future<void> initialize() async {
    await Future.wait([loadCategories(), loadProducts(reset: true)]);
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (reset) {
      state = state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        hasError: false,
        errorMessage: null,
        skip: 0,
        hasNextPage: true,
      );
    }

    final int currentSkip = reset ? 0 : state.skip;
    final String query = state.searchQuery.trim();
    final String? category = state.selectedCategorySlug;

    Result<ProductResponseModel> result;

    if (query.isNotEmpty) {
      result = await _repository.searchProducts(query);
    } else if (category != null && category.isNotEmpty) {
      result = await _repository.getProductsByCategory(category);
    } else {
      final pageQuery = PaginationQuery(
        pageSize: state.limit,
        page: (currentSkip ~/ state.limit) + 1,
      );
      result = await _repository.getProducts(
        limit: state.limit,
        skip: currentSkip,
        pagination: pageQuery,
      );
    }

    result.when(
      success: (response) {
        final newProducts = reset
            ? response.products
            : [...state.products, ...response.products];

        final bool hasMore =
            (query.isEmpty && (category == null || category.isEmpty))
            ? response.hasMore
            : false;

        state = state.copyWith(
          products: newProducts,
          isLoading: false,
          isLoadingMore: false,
          hasError: false,
          errorMessage: null,
          skip: newProducts.length,
          hasNextPage: hasMore,
        );
      },
      failure: (exception) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          hasError: true,
          errorMessage: exception.message,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);

    final pageQuery = PaginationQuery(
      pageSize: state.limit,
      page: (state.skip ~/ state.limit) + 1,
    );

    final result = await _repository.getProducts(
      limit: state.limit,
      skip: state.skip,
      pagination: pageQuery,
    );

    result.when(
      success: (response) {
        final combined = [...state.products, ...response.products];
        final bool hasMore = response.hasMore;

        state = state.copyWith(
          products: combined,
          isLoadingMore: false,
          skip: combined.length,
          hasNextPage: hasMore,
        );
      },
      failure: (exception) {
        state = state.copyWith(isLoadingMore: false);
      },
    );
  }

  Future<void> refresh() async {
    await loadProducts(reset: true);
  }

  void setSearch(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query, selectedCategorySlug: null);
    loadProducts(reset: true);
  }

  void setCategory(String? slug) {
    final effectiveSlug = (slug != null && slug.trim().isNotEmpty)
        ? slug.trim()
        : null;
    if (state.selectedCategorySlug == effectiveSlug &&
        state.searchQuery.isEmpty) {
      return;
    }
    state = state.copyWith(
      selectedCategorySlug: effectiveSlug,
      searchQuery: '',
    );
    loadProducts(reset: true);
  }

  void clearFilters() {
    state = state.copyWith(searchQuery: '', selectedCategorySlug: null);
    loadProducts(reset: true);
  }

  Future<void> loadCategories() async {
    final result = await _repository.getCategories();
    result.when(
      success: (categories) {
        _ref.read(categoryListProvider.notifier).state = categories;
      },
      failure: (_) {},
    );
  }
}
