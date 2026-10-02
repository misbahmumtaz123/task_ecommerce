import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../controllers/favorites_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../repositories/product_repository.dart';
import '../widgets/cart_badge_button.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final ProductModel? initialProduct;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductRepository? _repository;
  ProductModel? _product;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedImageIndex = 0;
  int _selectedQuantity = 1;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.initialProduct != null) {
      _product = widget.initialProduct;
    } else {
      _isLoading = true;
    }
    _selectedQuantity = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProduct();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_repository == null) {
      try {
        _repository = context.read<ProductRepository>();
      } catch (_) {
        _repository = ProductRepositoryImpl();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchProduct() async {
    final repo = _repository ?? ProductRepositoryImpl();
    final result = await repo.getProductById(widget.productId);
    if (!mounted) return;

    result.when(
      success: (data) {
        setState(() {
          _product = data;
          _isLoading = false;
          _errorMessage = null;
        });
      },
      failure: (exception) {
        setState(() {
          _isLoading = false;
          if (_product == null) {
            _errorMessage = exception.message;
          }
        });
      },
    );
  }

  List<String> _buildImageList() {
    if (_product == null) return [];
    final images = <String>[];
    for (final img in _product!.images) {
      final clean = img.trim();
      if (clean.isNotEmpty && !images.contains(clean)) {
        images.add(clean);
      }
    }
    final thumb = _product!.thumbnail.trim();
    if (thumb.isNotEmpty && !images.contains(thumb)) {
      images.add(thumb);
    }
    return images;
  }

  void _incrementQuantity() {
    final maxStock = _product?.stock ?? 1;
    if (_selectedQuantity < maxStock && _selectedQuantity < 99) {
      setState(() => _selectedQuantity++);
    }
  }

  void _decrementQuantity() {
    if (_selectedQuantity > 1) {
      setState(() => _selectedQuantity--);
    }
  }

  void _openImageZoom(String imageUrl) {
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
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fiber_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesController = Get.isRegistered<FavoritesController>()
        ? Get.find<FavoritesController>()
        : Get.put(FavoritesController(), permanent: true);

    final images = _buildImageList();

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            _product != null
                ? _product!.category.toUpperCase()
                : 'PRODUCT DETAILS',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            Obx(() {
              final isFav = favoritesController.isFavorite(widget.productId);
              return IconButton(
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.error : AppColors.textPrimary,
                ),
                onPressed: () {
                  if (_product != null) {
                    favoritesController.toggleFavorite(_product!);
                  }
                },
              );
            }),
            CartBadgeButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _buildBody(images),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBody(List<String> images) {
    if (_isLoading && _product == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Loading product details...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }
    if (_errorMessage != null && _product == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = true;
                  });
                  _fetchProduct();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_product == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'Product Not Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 768;
    final galleryHeight = (MediaQuery.sizeOf(context).height * 0.38).clamp(
      240.0,
      420.0,
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGallery(images, galleryHeight),
              const SizedBox(height: 20),
              _buildProductInfo(),
              const SizedBox(height: 24),
              _buildReviewsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallery(List<String> images, double height) {
    if (images.isEmpty) {
      final thumb = _product?.thumbnail ?? '';
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: thumb.isNotEmpty
              ? Image.network(
                  thumb,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => _selectedImageIndex = index);
                  },
                  itemBuilder: (_, i) {
                    return GestureDetector(
                      onTap: () => _openImageZoom(images[i]),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.network(
                          images[i],
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, _, _) {
                            final thumb = _product?.thumbnail.trim() ?? '';
                            if (thumb.isNotEmpty && images[i] != thumb) {
                              return Image.network(
                                thumb,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    size: 64,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              );
                            }
                            return const Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 64,
                                color: AppColors.textMuted,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    key: const Key('product_image_new_tag'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fiber_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedImageIndex + 1} / ${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Dot indicator row
                if (images.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (i) {
                        final isCurrent = i == _selectedImageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: isCurrent ? 20 : 6,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (_, i) {
                    final isSelected = i == _selectedImageIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedImageIndex = i);
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2.2 : 1,
                          ),
                          color: AppColors.surfaceVariant,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            images[i],
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.broken_image_rounded,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    final product = _product!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.brand != null && product.brand!.isNotEmpty)
              _badge(
                product.brand!,
                bg: AppColors.primaryLight,
                fg: AppColors.primaryDark,
              ),
            _badge(
              product.category.toUpperCase(),
              bg: AppColors.surfaceVariant,
              fg: AppColors.textSecondary,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (product.reviews.isNotEmpty)
                    Text(
                      ' (${product.reviews.length})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          product.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        if (product.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: product.tags
                .map(
                  (t) => Text(
                    '#$t',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: [
            Text(
              CurrencyFormatter.format(product.price),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (product.discountPercentage > 0) ...[
              Text(
                CurrencyFormatter.format(product.originalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${product.discountPercentage.round()}% OFF',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Save ${CurrencyFormatter.format(product.savingsAmount)}',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),
        const Text(
          'About the Product',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: const TextStyle(
            fontSize: 14.5,
            color: AppColors.textSecondary,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Product Specifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildSpecSection(product),
      ],
    );
  }

  Widget _badge(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSpecSection(ProductModel product) {
    final specs = [
      _SpecData(
        icon: Icons.inventory_2_outlined,
        title: 'Stock Status',
        value:
            product.availabilityStatus ??
            (product.stock > 0
                ? 'In Stock (${product.stock} units)'
                : 'Out of Stock'),
        highlight: product.stock > 0,
      ),
      _SpecData(
        icon: Icons.local_shipping_outlined,
        title: 'Shipping',
        value: product.shippingInformation ?? 'Standard Delivery',
      ),
      _SpecData(
        icon: Icons.verified_user_outlined,
        title: 'Warranty',
        value: product.warrantyInformation ?? 'Brand Warranty',
      ),
      _SpecData(
        icon: Icons.assignment_return_outlined,
        title: 'Return Policy',
        value: product.returnPolicy ?? '30 Days Return',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final isVeryNarrow = constraints.maxWidth < 280;
        final crossAxisCount = isWide ? 4 : (isVeryNarrow ? 1 : 2);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: specs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 84,
          ),
          itemBuilder: (context, index) => _specTile(specs[index]),
        );
      },
    );
  }

  Widget _specTile(_SpecData spec) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (spec.highlight ? AppColors.success : AppColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                spec.icon,
                size: 20,
                color: spec.highlight ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  spec.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  spec.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: spec.highlight
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final product = _product!;
    if (product.reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 28,
              color: AppColors.textMuted,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No customer reviews yet.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Customer Reviews (${product.reviews.length})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${product.rating.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...product.reviews.map(
          (review) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 15,
                          color: i < review.rating
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                    ),
                  ],
                ),
                if (review.date.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(review.date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_product == null) return const SizedBox.shrink();

    final product = _product!;
    final maxStock = product.stock > 0 ? product.stock : 1;
    final totalPrice = product.price * _selectedQuantity;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          color: _selectedQuantity > 1
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: _decrementQuantity,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$_selectedQuantity',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          color: _selectedQuantity < maxStock
                              ? AppColors.primary
                              : AppColors.textMuted,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: _incrementQuantity,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: product.stock <= 0
                          ? null
                          : () {
                              context.read<CartProvider>().addItemWithQuantity(
                                product,
                                _selectedQuantity,
                              );
                              final messenger = ScaffoldMessenger.of(context);
                              messenger.hideCurrentSnackBar();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$_selectedQuantity × ${product.title} added to cart!',
                                  ),
                                  duration: const Duration(milliseconds: 2000),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'VIEW CART',
                                    textColor: Colors.amber,
                                    onPressed: () {
                                      messenger.hideCurrentSnackBar();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const CartScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 20,
                      ),
                      label: Text(
                        product.stock > 0
                            ? 'Add to Cart • ${CurrencyFormatter.format(totalPrice)}'
                            : 'Out of Stock',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        disabledForegroundColor: AppColors.textMuted,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _SpecData {
  final IconData icon;
  final String title;
  final String value;
  final bool highlight;
  const _SpecData({
    required this.icon,
    required this.title,
    required this.value,
    this.highlight = false,
  });
}
