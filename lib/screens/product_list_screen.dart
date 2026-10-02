import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart'
    hide Consumer, Provider, ChangeNotifierProvider;

import '../controllers/auth_controller.dart';
import '../controllers/favorites_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/routing/app_routes.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/category_list_provider.dart';
import '../providers/product_list_notifier.dart';
import '../providers/product_list_state.dart';
import '../widgets/cart_badge_button.dart';
import '../widgets/category_selector.dart';
import '../widgets/product_card.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/state_views.dart';
import '../controllers/navigation_controller.dart';
import '../core/utils/enums/sort_option.dart';
import '../models/user_model.dart';
import '../services/tutorial_service.dart';

/// Product listing screen powered completely by Riverpod state management.
/// Demonstrates ref.watch(), ref.read(), ref.listen(), and rebuild optimization using select().
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  Timer? _tutorialTimer;
  SortOption _selectedSort = SortOption.featured;

  // Tutorial Coach Mark Feature Keys
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _categoriesKey = GlobalKey();
  final GlobalKey _sortKey = GlobalKey();
  final GlobalKey _favoritesKey = GlobalKey();
  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initTutorial();
  }

  void _initTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tutorialTimer?.cancel();
      // Slight delay so header and action elements are fully laid out
      _tutorialTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        TutorialService.showTutorialIfNeeded(
          context: context,
          searchKey: _searchKey,
          categoriesKey: _categoriesKey,
          sortKey: _sortKey,
          favoritesKey: _favoritesKey,
          cartKey: _cartKey,
          profileKey: _profileKey,
        );
      });
    });
  }

  @override
  void dispose() {
    _tutorialTimer?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Load next page when reaching 300px before end or at bottom
    if (currentScroll >= (maxScroll - 300)) {
      ref.read(productListNotifierProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(productListNotifierProvider.notifier).setSearch(query);
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    ref.read(productListNotifierProvider.notifier).setSearch('');
  }

  List<ProductModel> _applySorting(List<ProductModel> items) {
    final list = List<ProductModel>.from(items);
    switch (_selectedSort) {
      case SortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingHighToLow:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.featured:
        // Keep DummyJSON default order
        break;
    }
    return list;
  }

  Widget _buildGlassSortDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.9),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: PopupMenuButton<SortOption>(
            initialValue: _selectedSort,
            onSelected: (option) {
              setState(() => _selectedSort = option);
            },
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            color: AppColors.surface.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppColors.border.withValues(alpha: 0.85),
                width: 1.0,
              ),
            ),
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedSort.label,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => SortOption.values.map((option) {
              final isSelected = _selectedSort == option;
              return PopupMenuItem<SortOption>(
                value: option,
                height: 42,
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedHeader({
    required List<CategoryModel> categories,
    required String? selectedCategorySlug,
    required List<ProductModel> products,
    required bool isLoadingInitial,
    required bool hasInitialError,
  }) {
    return Container(
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Search Input Field
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: KeyedSubtree(
              key: _searchKey,
              child: ProductSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _onClearSearch,
              ),
            ),
          ),

          // 2. Horizontal Categories Selector (Filters)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: KeyedSubtree(
              key: _categoriesKey,
              child: CategorySelector(
                categories: categories,
                selectedSlug: selectedCategorySlug,
                onSelectCategory: (slug) {
                  _searchController.clear();
                  ref
                      .read(productListNotifierProvider.notifier)
                      .setCategory(slug);
                },
              ),
            ),
          ),

          // 3. Count & Sort Bar (Pagination count and Sort)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isLoadingInitial
                      ? 'Loading catalog...'
                      : '${products.length} Products',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                KeyedSubtree(
                  key: _sortKey,
                  child: _buildGlassSortDropdown(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _showUserMenu(
    BuildContext context,
    AuthController authController,
    UserModel user,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: user.image != null
                    ? NetworkImage(user.image!)
                    : null,
                child: user.image == null
                    ? Text(
                        user.firstName.isNotEmpty
                            ? user.firstName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '@${user.username} • ${user.email}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              ListTile(
                leading: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'App Feature Tour',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Replay guided feature walkthrough',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  TutorialService.showTutorialIfNeeded(
                    context: context,
                    searchKey: _searchKey,
                    categoriesKey: _categoriesKey,
                    sortKey: _sortKey,
                    favoritesKey: _favoritesKey,
                    cartKey: _cartKey,
                    profileKey: _profileKey,
                    force: true,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  if (Navigator.of(ctx).canPop()) {
                    Navigator.of(ctx).pop();
                  }
                  await authController.logout();
                  if (Get.isRegistered<NavigationController>()) {
                    Get.find<NavigationController>().toLogin();
                  } else {
                    Get.offAllNamed(AppRoutes.login);
                  }
                  Get.snackbar(
                    'Signed Out',
                    'You have been signed out successfully.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Demonstrate ref.listen() for asynchronous side-effects (e.g., showing a floating error snackbar)
    ref.listen<ProductListState>(productListNotifierProvider, (previous, next) {
      if (next.hasError &&
          next.products.isNotEmpty &&
          previous?.hasError != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Failed to update catalog'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // 2. Demonstrate rebuild optimization using select()
    final isLoadingInitial = ref.watch(
      productListNotifierProvider.select(
        (state) => state.isLoading && state.products.isEmpty,
      ),
    );

    final hasInitialError = ref.watch(
      productListNotifierProvider.select(
        (state) => state.hasError && state.products.isEmpty,
      ),
    );

    final errorMessage = ref.watch(
      productListNotifierProvider.select((state) => state.errorMessage),
    );

    final products = ref.watch(
      productListNotifierProvider.select((state) => state.products),
    );

    final isLoadingMore = ref.watch(
      productListNotifierProvider.select((state) => state.isLoadingMore),
    );

    final hasNextPage = ref.watch(
      productListNotifierProvider.select((state) => state.hasNextPage),
    );

    final selectedCategorySlug = ref.watch(
      productListNotifierProvider.select((state) => state.selectedCategorySlug),
    );

    final searchQuery = ref.watch(
      productListNotifierProvider.select((state) => state.searchQuery),
    );

    // Watch category list separately
    final categories = ref.watch(categoryListProvider);

    // GetX FavoritesController for reactive badge
    final favoritesController = Get.find<FavoritesController>();

    final sortedProducts = _applySorting(products);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Discover',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Favorites Button with reactive count badge using GetX Obx
          KeyedSubtree(
            key: _favoritesKey,
            child: Obx(() {
              final count = favoritesController.count;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.textPrimary,
                    ),
                    tooltip: 'Favorites',
                    onPressed: () {
                      NavigationController.to.toFavorites();
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          // Shopping Cart Action
          KeyedSubtree(
            key: _cartKey,
            child: CartBadgeButton(
              onPressed: () => NavigationController.to.toCart(context),
            ),
          ),
          const SizedBox(width: 4),
          // User Profile / Auth Action (GetX Obx)
          KeyedSubtree(
            key: _profileKey,
            child: Obx(() {
              final authController = Get.find<AuthController>();
              final user = authController.currentUser;
              if (user != null) {
                return GestureDetector(
                  onTap: () => _showUserMenu(context, authController, user),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: user.image != null
                          ? NetworkImage(user.image!)
                          : null,
                      child: user.image == null
                          ? Text(
                              user.firstName.isNotEmpty
                                  ? user.firstName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.textPrimary,
                ),
                tooltip: 'Sign In',
                onPressed: () => NavigationController.to.toLoginModal(),
              );
            }),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _buildFixedHeader(
                categories: categories,
                selectedCategorySlug: selectedCategorySlug,
                products: products,
                isLoadingInitial: isLoadingInitial,
                hasInitialError: hasInitialError,
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    // Use ref.read() for actions
                    await ref
                        .read(productListNotifierProvider.notifier)
                        .refresh();
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Main Content Area
                      if (isLoadingInitial)
                        const SliverFillRemaining(
                          child: LoadingView(message: 'Fetching products...'),
                        )
                      else if (hasInitialError)
                        SliverFillRemaining(
                          child: ErrorView(
                            message:
                                errorMessage ?? 'An unexpected error occurred.',
                            onRetry: () {
                              ref
                                  .read(productListNotifierProvider.notifier)
                                  .loadProducts(reset: true);
                            },
                          ),
                        )
                      else if (products.isEmpty)
                        SliverFillRemaining(
                          child: EmptyView(
                            title: 'No Products Found',
                            subtitle: searchQuery.isNotEmpty
                                ? 'No results matched "$searchQuery". Try another keyword.'
                                : 'No products in this category yet.',
                            actionLabel: 'Reset Filters',
                            onAction: () {
                              _searchController.clear();
                              ref
                                  .read(productListNotifierProvider.notifier)
                                  .clearFilters();
                            },
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio:
                                      (0.63 /
                                              MediaQuery.textScalerOf(
                                                context,
                                              ).scale(1.0))
                                          .clamp(0.54, 0.70),
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = sortedProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).clearSnackBars();
                                  NavigationController.to.toProductDetail(
                                    product.id,
                                    initialProduct: product,
                                  );
                                },
                                onAddToCart: () {
                                  context.read<CartProvider>().addItem(product);
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  messenger.hideCurrentSnackBar();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.title} added to cart!',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              );
                            }, childCount: sortedProducts.length),
                          ),
                        ),

                      // Pagination Loading Indicator
                      if (isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // End of Catalog indicator
                      if (!isLoadingMore &&
                          !hasNextPage &&
                          sortedProducts.isNotEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'You have reached the end of the catalog',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
