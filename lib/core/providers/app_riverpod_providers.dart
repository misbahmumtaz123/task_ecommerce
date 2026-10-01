import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_list_notifier.dart';
import '../../repositories/product_repository.dart';

/// Dedicated class and widget for configuring Riverpod providers and scope overrides.
/// Keeps main.dart clean and free of Riverpod setup boilerplate.
class AppRiverpodProviders extends StatelessWidget {
  final ProductRepository productRepository;
  final Widget child;

  const AppRiverpodProviders({
    super.key,
    required this.productRepository,
    required this.child,
  });

  /// Riverpod overrides list for testing and injection
  static List<Override> overrides(ProductRepository repository) => [
    productRepositoryProvider.overrideWithValue(repository),
  ];

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides(productRepository),
      child: child,
    );
  }
}
