import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/screens/onboarding_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestApp() {
    return const GetMaterialApp(
      home: OnboardingScreen(),
    );
  }

  testWidgets('OnboardingScreen renders responsively on standard phone without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Verify header with logo and skip button
    expect(find.text('AuraStore'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Verify first slide content
    expect(find.text('Discover Latest Trends & Curated Tech'), findsOneWidget);
    expect(find.text('10,000+ PRODUCTS'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('OnboardingScreen adapts to short phone screen without overflow or bottom void', (tester) async {
    tester.view.physicalSize = const Size(360, 640); // Compact phone
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('AuraStore'), findsOneWidget);
    expect(find.text('Discover Latest Trends & Curated Tech'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Verify button is on screen and visible
    expect(tester.getTopLeft(find.text('Continue')).dy, lessThan(640.0));
  });

  testWidgets('OnboardingScreen adapts to tall phone screen and balances layout', (tester) async {
    tester.view.physicalSize = const Size(430, 932); // Tall phone (Pro Max)
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('AuraStore'), findsOneWidget);
    expect(find.text('Discover Latest Trends & Curated Tech'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
