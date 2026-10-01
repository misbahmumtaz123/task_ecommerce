import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart' as p;
import 'package:ecommerce_app/controllers/auth_controller.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/controllers/detail_controller.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/app.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/providers/product_list_notifier.dart';
import 'package:ecommerce_app/repositories/auth_repository.dart';
import 'package:ecommerce_app/repositories/product_repository.dart';
import 'package:ecommerce_app/services/auth_api_service.dart';
import 'package:ecommerce_app/services/product_api_service.dart';

void main() {
  testWidgets('EcommerceApp smoke test', (WidgetTester tester) async {
    final apiClient = ApiClient();
    final apiService = ProductApiServiceImpl(client: apiClient);
    final repository = ProductRepositoryImpl(apiService: apiService);

    final authApiService = AuthApiServiceImpl(client: apiClient);
    final authRepository = AuthRepositoryImpl(apiService: authApiService);

    Get.put<FavoritesController>(FavoritesController());
    Get.put<DetailController>(DetailController(repository));
    Get.put<AuthController>(AuthController(authRepository: authRepository));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repository),
        ],
        child: p.MultiProvider(
          providers: [
            p.ChangeNotifierProvider(
              create: (_) => CartProvider(),
            ),
          ],
          child: const EcommerceApp(),
        ),
      ),
    );

    // Initial Splash Screen displays AuraStore title
    expect(find.text('AuraStore'), findsOneWidget);

    // Let the splash screen timer finish and transition to Onboarding
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Onboarding Screen is presented
    expect(find.text('Skip'), findsOneWidget);
  });
}
