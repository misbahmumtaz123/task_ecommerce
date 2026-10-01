import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

/// State for the product listing feature handled by Riverpod.
/// It contains the list of products, loading flags, pagination info,
/// current search query and selected category.
class ProductListState {
  final List<ProductModel> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final bool hasNextPage;
  final int skip;
  final int limit;
  final String searchQuery;
  final String? selectedCategorySlug;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.hasNextPage = true,
    this.skip = 0,
    this.limit = 30,
    this.searchQuery = '',
    this.selectedCategorySlug,
  });

  ProductListState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    bool? hasNextPage,
    int? skip,
    int? limit,
    String? searchQuery,
    String? selectedCategorySlug,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategorySlug: selectedCategorySlug ?? this.selectedCategorySlug,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductListState &&
          runtimeType == other.runtimeType &&
          listEquals(products, other.products) &&
          isLoading == other.isLoading &&
          isLoadingMore == other.isLoadingMore &&
          hasError == other.hasError &&
          errorMessage == other.errorMessage &&
          hasNextPage == other.hasNextPage &&
          skip == other.skip &&
          limit == other.limit &&
          searchQuery == other.searchQuery &&
          selectedCategorySlug == other.selectedCategorySlug;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(products),
        isLoading,
        isLoadingMore,
        hasError,
        errorMessage,
        hasNextPage,
        skip,
        limit,
        searchQuery,
        selectedCategorySlug,
      );
}
