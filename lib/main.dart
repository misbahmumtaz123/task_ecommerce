import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:get/get.dart';
import 'package:provider/provider.dart' as provider_pkg;

import 'core/constants/app_colors.dart';
import 'core/di/app_dependencies.dart';
import 'core/network/api_client.dart';
import 'providers/cart_provider.dart';
import 'providers/product_list_notifier.dart';
import 'providers/product_provider.dart';
import 'repositories/product_repository.dart';
import 'screens/splash_screen.dart';
import 'services/product_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize network & data layer dependencies
  final apiClient = ApiClient();
  final apiService = ProductApiServiceImpl(client: apiClient);
  final productRepository = ProductRepositoryImpl(apiService: apiService);

  // Initialize GetX dependencies & controllers (FavoritesController, AuthController, DetailController)
  AppDependencies.init(
    apiClient: apiClient,
    productRepository: productRepository,
  );

  runApp(
    riverpod.ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepository),
      ],
      child: provider_pkg.MultiProvider(
        providers: [
          // Repository provider for access across the widget tree
          provider_pkg.Provider<ProductRepository>.value(value: productRepository),

          // State Management providers
          provider_pkg.ChangeNotifierProvider<ProductProvider>(
            create: (_) => ProductProvider(repository: productRepository),
          ),
          provider_pkg.ChangeNotifierProvider<CartProvider>(
            create: (_) => CartProvider(),
          ),
        ],
        child: const EcommerceApp(),
      ),
    ),
  );
}

class EcommerceApp extends StatelessWidget {
  final Widget? home;
  const EcommerceApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DummyJSON Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: home ?? const SplashScreen(),
    );
  }
}
