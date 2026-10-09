import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketupdates/Services/market_feed.dart';
import 'package:marketupdates/main.dart';
import 'package:marketupdates/Designs/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    MarketFeed.instance.stop();
  });

  testWidgets('Splash shows logo then opens watchlist', (WidgetTester tester) async {
    await tester.pumpWidget(const TradingApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }

    expect(find.text('My Stocks (4)'), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);

    await tester.tap(find.text('Market'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Live Market'), findsOneWidget);
    expect(find.text('RELIANCE'), findsWidgets);

    await tester.tap(find.text('Holdings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No holdings yet'), findsOneWidget);

    await tester.tap(find.text('Orders'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No orders yet'), findsOneWidget);
    MarketFeed.instance.stop();
  });
}
