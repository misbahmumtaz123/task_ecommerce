import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/app_initializer.dart';
import 'core/providers/app_riverpod_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppInitializer.init();

  runApp(
    AppRiverpodProviders(
      productRepository: dependencies.productRepository,
      child: EcommerceApp(dependencies: dependencies),
    ),
  );
}
