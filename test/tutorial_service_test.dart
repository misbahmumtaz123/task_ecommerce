import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_app/services/tutorial_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TutorialService Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial hasSeenTutorial returns false for first-time user', () async {
      final seen = await TutorialService.hasSeenTutorial();
      expect(seen, isFalse);
    });

    test('markTutorialCompleted sets flag to true', () async {
      await TutorialService.markTutorialCompleted();
      final seen = await TutorialService.hasSeenTutorial();
      expect(seen, isTrue);
    });

    test('resetTutorial clears completed flag back to false', () async {
      await TutorialService.markTutorialCompleted();
      expect(await TutorialService.hasSeenTutorial(), isTrue);

      await TutorialService.resetTutorial();
      expect(await TutorialService.hasSeenTutorial(), isFalse);
    });
  });

  group('TutorialService Integration Tests', () {
    testWidgets('showTutorialIfNeeded respects seen flag and mounts targets', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'has_seen_main_tutorial_v1': true});

      final searchKey = GlobalKey();
      final categoriesKey = GlobalKey();
      final sortKey = GlobalKey();
      final favoritesKey = GlobalKey();
      final cartKey = GlobalKey();
      final profileKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: searchKey),
                Container(key: categoriesKey),
                Container(key: sortKey),
                Container(key: favoritesKey),
                Container(key: cartKey),
                Container(key: profileKey),
              ],
            ),
          ),
        ),
      );

      // Should not throw or crash when already seen
      await TutorialService.showTutorialIfNeeded(
        context: tester.element(find.byType(Scaffold)),
        searchKey: searchKey,
        categoriesKey: categoriesKey,
        sortKey: sortKey,
        favoritesKey: favoritesKey,
        cartKey: cartKey,
        profileKey: profileKey,
      );

      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
