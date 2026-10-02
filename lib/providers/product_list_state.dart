import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

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
    this.limit = 6,
    this.searchQuery = '',
    this.selectedCategorySlug,
  });

  static const Object _sentinel = Object();

  ProductListState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    Object? errorMessage = _sentinel,
    bool? hasNextPage,
    int? skip,
    int? limit,
    String? searchQuery,
    Object? selectedCategorySlug = _sentinel,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategorySlug: identical(selectedCategorySlug, _sentinel)
          ? this.selectedCategorySlug
          : selectedCategorySlug as String?,
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
