import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  const testProduct = ProductModel(
    id: 1,
    title: 'Essence Mascara',
    description: 'A lash mascara',
    category: 'beauty',
    price: 9.99,
    stock: 20,
    thumbnail: 'https://dummyjson.com/image.jpg',
  );

  Widget buildTestApp(CartProvider cartProvider) {
    return ChangeNotifierProvider<CartProvider>.value(
      value: cartProvider,
      child: const GetMaterialApp(
        home: CartScreen(),
      ),
    );
  }

  testWidgets('Clear cart dialog opens and shows 2 stylish buttons: Cancel and Clear', (tester) async {
    final cartProvider = CartProvider();
    cartProvider.addItem(testProduct);

    await tester.pumpWidget(buildTestApp(cartProvider));
    await tester.pumpAndSettle();

    // Verify cart has item and "Clear" button in app bar is visible
    expect(cartProvider.itemCount, equals(1));
    final clearAppBarBtn = find.widgetWithText(TextButton, 'Clear');
    expect(clearAppBarBtn, findsOneWidget);

    // Tap Clear in app bar to trigger the clear cart dialog
    await tester.tap(clearAppBarBtn);
    await tester.pumpAndSettle();

    // Verify stylish dialog content
    expect(find.text('Clear Cart?'), findsOneWidget);
    expect(
      find.text('Are you sure you want to remove all items from your shopping cart? This action cannot be undone.'),
      findsOneWidget,
    );

    // Verify the 2 stylish buttons exist
    final cancelBtn = find.widgetWithText(OutlinedButton, 'Cancel');
    final clearDialogBtn = find.widgetWithText(ElevatedButton, 'Clear');

    expect(cancelBtn, findsOneWidget);
    expect(clearDialogBtn, findsOneWidget);

    // Tap Cancel -> dialog should dismiss, cart items remain
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    expect(find.text('Clear Cart?'), findsNothing);
    expect(cartProvider.itemCount, equals(1));

    // Tap Clear again and confirm clearing
    await tester.tap(clearAppBarBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Clear'));
    await tester.pumpAndSettle();

    // Dialog dismissed and cart is cleared
    expect(find.text('Clear Cart?'), findsNothing);
    expect(cartProvider.itemCount, equals(0));
    expect(find.text('Your Cart is Empty'), findsOneWidget);
  });
}
