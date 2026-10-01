import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

enum ProductSortOption {
  featured,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
}

/// Controller responsible for UI-level input orchestration:
/// - Search debouncing
/// - Sorting filters
/// - Coordinating actions with [ProductProvider]
class ProductController {
  final ProductProvider _productProvider;
  final TextEditingController searchTextController = TextEditingController();
  Timer? _debounceTimer;

  ProductSortOption currentSort = ProductSortOption.featured;

  ProductController({required ProductProvider productProvider})
      : _productProvider = productProvider;

  /// Handles search text input with a 500ms debounce
  void onSearchChanged(String query, {Duration debounceTime = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceTime, () {
      _productProvider.searchProducts(query);
    });
  }

  /// Clears search and restores catalog
  void clearSearch() {
    searchTextController.clear();
    _debounceTimer?.cancel();
    _productProvider.fetchAllProducts();
  }

  /// Applies category filter
  void onCategorySelected(String? slug) {
    searchTextController.clear();
    _debounceTimer?.cancel();
    _productProvider.selectCategory(slug);
  }

  /// Sorts products according to the selected criterion
  List<ProductModel> getSortedProducts() {
    final list = List<ProductModel>.from(_productProvider.products);

    switch (currentSort) {
      case ProductSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.ratingHighToLow:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProductSortOption.featured:
        // Default API order
        break;
    }

    return list;
  }

  void dispose() {
    _debounceTimer?.cancel();
    searchTextController.dispose();
  }
}
