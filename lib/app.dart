import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'core/bindings/app_binding.dart';
import 'core/di/app_dependencies.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'repositories/product_repository.dart';

class EcommerceApp extends StatelessWidget {
  final AppDependencies? dependencies;
  final Widget? home;
  const EcommerceApp({super.key, this.dependencies, this.home});
  @override
  Widget build(BuildContext context) {
    final deps = dependencies ?? AppDependencies.init();
    return provider_pkg.MultiProvider(
      providers: [
        provider_pkg.Provider<ProductRepository>.value(
          value: deps.productRepository,
        ),
        provider_pkg.ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(repository: deps.productRepository),
        ),
        provider_pkg.ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
      ],
      child: GetMaterialApp(
        title: 'Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialBinding: AppBinding(),
        getPages: AppRouter.routes,
        initialRoute: home == null ? AppRouter.initialRoute : null,
        home: home,
      ),
    );
  }
}
