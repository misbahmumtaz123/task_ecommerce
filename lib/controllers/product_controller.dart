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

class ProductController {
  final ProductProvider _productProvider;
  final TextEditingController searchTextController = TextEditingController();
  Timer? _debounceTimer;

  ProductSortOption currentSort = ProductSortOption.featured;

  ProductController({required ProductProvider productProvider})
    : _productProvider = productProvider;

  void onSearchChanged(
    String query, {
    Duration debounceTime = const Duration(milliseconds: 500),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceTime, () {
      _productProvider.searchProducts(query);
    });
  }

  void clearSearch() {
    searchTextController.clear();
    _debounceTimer?.cancel();
    _productProvider.fetchAllProducts();
  }

  void onCategorySelected(String? slug) {
    searchTextController.clear();
    _debounceTimer?.cancel();
    _productProvider.selectCategory(slug);
  }

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
        break;
    }

    return list;
  }

  void dispose() {
    _debounceTimer?.cancel();
    searchTextController.dispose();
  }
}
