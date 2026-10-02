import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/controllers/auth_controller.dart';
import 'package:ecommerce_app/repositories/auth_repository.dart';
import 'package:ecommerce_app/services/auth_api_service.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/screens/auth/login_screen.dart';

void main() {
  setUp(() {
    Get.reset();
    final apiClient = ApiClient();
    final authApiService = AuthApiServiceImpl(client: apiClient);
    final authRepository = AuthRepositoryImpl(apiService: authApiService);
    Get.put<AuthController>(AuthController(authRepository: authRepository));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('LoginScreen is non-scrollable and renders all essential components', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: LoginScreen(),
      ),
    );

    // Verify Welcome Back title and brand presence
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Verify there is no SingleChildScrollView or vertical Scrollable on the screen
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      find.byWidgetPredicate((w) =>
          w is Scrollable &&
          (w.axisDirection == AxisDirection.down ||
              w.axisDirection == AxisDirection.up)),
      findsNothing,
    );

    // Verify dragging the screen does not scroll it
    final initialPos = tester.getTopLeft(find.text('Welcome Back'));
    await tester.drag(find.text('Welcome Back'), const Offset(0, -100));
    await tester.pump();
    final newPos = tester.getTopLeft(find.text('Welcome Back'));
    expect(newPos, equals(initialPos));
  });
}
