import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart' as p;
import 'package:ecommerce_app/controllers/auth_controller.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/controllers/detail_controller.dart';
import 'package:ecommerce_app/controllers/navigation_controller.dart';
import 'package:ecommerce_app/core/routing/app_router.dart';
import 'package:ecommerce_app/core/routing/app_routes.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/providers/product_list_notifier.dart';
import 'package:ecommerce_app/repositories/auth_repository.dart';
import 'package:ecommerce_app/repositories/product_repository.dart';
import 'package:ecommerce_app/services/auth_api_service.dart';
import 'package:ecommerce_app/services/product_api_service.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProductRepository productRepository;
  late AuthRepository authRepository;

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({'has_seen_main_tutorial_v1': true});
    Get.reset();
    final apiClient = ApiClient();
    final authApiService = AuthApiServiceImpl(client: apiClient);
    authRepository = AuthRepositoryImpl(apiService: authApiService);
    final productApiService = ProductApiServiceImpl(client: apiClient);
    productRepository = ProductRepositoryImpl(apiService: productApiService);

    Get.put<ProductRepository>(productRepository);
    Get.put<AuthRepository>(authRepository);
    Get.put<FavoritesController>(FavoritesController());
    Get.put<DetailController>(DetailController(productRepository));
    Get.put<AuthController>(AuthController(authRepository: authRepository));
    Get.put<NavigationController>(NavigationController(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestApp(String initialRoute) {
    return ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepository),
      ],
      child: p.MultiProvider(
        providers: [
          p.ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: GetMaterialApp(
          key: UniqueKey(),
          initialRoute: initialRoute,
          getPages: AppRouter.routes,
        ),
      ),
    );
  }

  testWidgets('Email and password validation prevents proceeding on LoginScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(AppRoutes.login));
    await tester.pumpAndSettle();

    // Tap Sign In with empty fields
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify validation errors are shown
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    // Enter invalid email format
    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'notanemail');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);

    // Enter short password (< 8 chars)
    await tester.enterText(passwordField, 'short');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 8 characters long'), findsOneWidget);

    // Enter password without uppercase
    await tester.enterText(passwordField, 'password@123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Password must contain at least one uppercase letter'), findsOneWidget);

    // Enter password without digit
    await tester.enterText(passwordField, 'Password@');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Password must contain at least one digit'), findsOneWidget);

    // Enter password without special character
    await tester.enterText(passwordField, 'Password123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Password must contain at least one special character'), findsOneWidget);

    // Enter valid email and valid password (fulfilling all conditions)
    await tester.enterText(emailField, 'shopper@example.com');
    await tester.enterText(passwordField, 'Secure@Pass2026');
    await tester.tap(find.text('Sign In'));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify user is authenticated locally without server auth
    final authController = Get.find<AuthController>();
    expect(authController.isAuthenticated, isTrue);
    expect(authController.currentUser?.email, 'shopper@example.com');
  });

  testWidgets('RegisterScreen First Name and Last Name fields are fixed and responsive', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844); // Standard mobile phone
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(AppRoutes.register));
    await tester.pumpAndSettle();

    final firstNameField = find.widgetWithText(TextFormField, 'First name');
    final lastNameField = find.widgetWithText(TextFormField, 'Last name');

    expect(firstNameField, findsOneWidget);
    expect(lastNameField, findsOneWidget);

    // Record initial vertical top offsets
    final initialFirstTop = tester.getTopLeft(firstNameField).dy;
    final initialLastTop = tester.getTopLeft(lastNameField).dy;

    // Both should be aligned horizontally at the same vertical offset on phone
    expect((initialFirstTop - initialLastTop).abs(), lessThan(1.0));

    // Type text into First Name field
    await tester.enterText(firstNameField, 'Alexander');
    await tester.pumpAndSettle();

    // Verify neither field shifted vertically when text is entered
    final newFirstTop = tester.getTopLeft(firstNameField).dy;
    final newLastTop = tester.getTopLeft(lastNameField).dy;
    expect(newFirstTop, equals(initialFirstTop));
    expect(newLastTop, equals(initialLastTop));

    // Test narrow phone (< 360 width) to verify responsive vertical stacking
    tester.view.physicalSize = const Size(320, 700);
    await tester.pumpAndSettle();

    final narrowFirstTop = tester.getTopLeft(firstNameField).dy;
    final narrowLastTop = tester.getTopLeft(lastNameField).dy;
    // On narrow screen, last name should be stacked below first name
    expect(narrowLastTop, greaterThan(narrowFirstTop));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('RegisterScreen validates password criteria and navigates to sign in page upon sign up', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(AppRoutes.register));
    await tester.pumpAndSettle();

    // Verify Register screen is displayed
    expect(find.text('Join AuraStore'), findsOneWidget);

    // Fill form with valid fields and valid password meeting all requirements
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'John'); // First Name
    await tester.enterText(textFields.at(1), 'Doe'); // Last Name
    await tester.enterText(textFields.at(2), 'johndoe'); // Username
    await tester.enterText(textFields.at(3), 'john.doe@example.com'); // Email
    await tester.enterText(textFields.at(4), 'Secure@Pass2026'); // Password: >=8 chars, uppercase, digit, special char

    // Submit form by clicking Create Account
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify navigation landed on Sign In page
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
