import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import 'favorites_controller.dart';

/// GetX Controller for the Product Details screen.
/// Fetches product details by ID and manages local screen states (image index, loading, error).
class DetailController extends GetxController {
  final ProductRepository repository;

  DetailController(this.repository);

  final Rxn<ProductModel> _product = Rxn<ProductModel>();
  ProductModel? get product => _product.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  final RxInt _selectedImageIndex = 0.obs;
  int get selectedImageIndex => _selectedImageIndex.value;

  void setSelectedImageIndex(int index) {
    _selectedImageIndex.value = index;
  }

  /// Returns unique cleaned image list for the product gallery
  List<String> get imageList {
    final p = _product.value;
    if (p == null) return [];
    final images = <String>[];
    for (final img in p.images) {
      final clean = img.trim();
      if (clean.isNotEmpty && !images.contains(clean)) {
        images.add(clean);
      }
    }
    final thumb = p.thumbnail.trim();
    if (thumb.isNotEmpty && !images.contains(thumb)) {
      images.add(thumb);
    }
    return images;
  }

  void prepareForProduct(int id, {ProductModel? initialProduct}) {
    if (initialProduct != null) {
      _product.value = initialProduct;
      _isLoading.value = false;
    } else if (_product.value?.id != id) {
      _product.value = null;
      _isLoading.value = true;
    }
    _errorMessage.value = '';
    _selectedImageIndex.value = 0;
    _selectedQuantity.value = 1;
  }

  final RxInt _selectedQuantity = 1.obs;
  int get selectedQuantity => _selectedQuantity.value;

  void incrementQuantity() {
    final stock = _product.value?.stock ?? 99;
    if (_selectedQuantity.value < stock) {
      _selectedQuantity.value++;
    }
  }

  void decrementQuantity() {
    if (_selectedQuantity.value > 1) {
      _selectedQuantity.value--;
    }
  }

  void setQuantity(int qty) {
    if (qty >= 1) {
      _selectedQuantity.value = qty;
    }
  }

  /// Hard resets all state — call this at the start of each new product detail navigation
  void reset() {
    _product.value = null;
    _isLoading.value = false;
    _errorMessage.value = '';
    _selectedImageIndex.value = 0;
    _selectedQuantity.value = 1;
  }

  /// Sets the product immediately to prevent blank/not found screen while fresh details load
  void setProduct(ProductModel product) {
    _product.value = product;
    _isLoading.value = false;
    _errorMessage.value = '';
    _selectedImageIndex.value = 0;
    _selectedQuantity.value = 1;
  }

  /// Prepares controller for loading a product by ID if no initial data is present
  void startLoadingForProduct(int id) {
    _product.value = null;
    _isLoading.value = true;
    _errorMessage.value = '';
    _selectedImageIndex.value = 0;
  }

  /// Fetches product details by product ID from repository with optional fallback.
  /// If [fallbackProduct] is provided it is shown immediately while the API loads fresh data.
  Future<void> fetchProduct(int id, {ProductModel? fallbackProduct}) async {
    if (fallbackProduct != null) {
      _product.value = fallbackProduct;
      _isLoading.value = false;
    } else if (_product.value?.id != id) {
      _product.value = null;
      _isLoading.value = true;
    }
    _errorMessage.value = '';
    _selectedImageIndex.value = 0;

    try {
      final result = await repository.getProductById(id);
      result.when(
        success: (data) {
          _product.value = data;
          _errorMessage.value = '';
        },
        failure: (exception) {
          if (_product.value == null) {
            _errorMessage.value = exception.message;
          }
          // If we have a fallback, we keep showing it silently on fetch failure
        },
      );
    } catch (e) {
      if (_product.value == null) {
        _errorMessage.value = 'Failed to load product: $e';
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// Check if the currently viewed product is favorited
  bool isFavorite(int id) {
    if (Get.isRegistered<FavoritesController>()) {
      return Get.find<FavoritesController>().isFavorite(id);
    }
    return false;
  }

  /// Toggle favorite status of current product
  void toggleFavorite() {
    final p = _product.value;
    if (p != null && Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().toggleFavorite(p);
    }
  }

  /// Open high-resolution image zoom modal dialog
  void openImageZoom(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_rounded,
                      size: 80,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.6)),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
