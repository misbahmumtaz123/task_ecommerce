import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;

import '../../providers/cart_provider.dart';
import '../../providers/product_list_notifier.dart';
import '../../repositories/product_repository.dart';

/// Clean architectural wrapper that bridges Riverpod (Product catalog, filters, pagination)
/// and Provider (Shopping Cart state) without causing namespace or identifier conflicts in main.dart.
class AppRootProviders extends StatelessWidget {
  final ProductRepository productRepository;
  final CartProvider? cartProvider;
  final Widget child;

  const AppRootProviders({
    super.key,
    required this.productRepository,
    this.cartProvider,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepository),
      ],
      child: provider_pkg.ChangeNotifierProvider<CartProvider>(
        create: (_) => cartProvider ?? CartProvider(),
        child: child,
      ),
    );
  }
}
