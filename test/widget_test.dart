import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketupdates/main.dart';
import 'package:marketupdates/splash_screen.dart';

void main() {
  testWidgets('Splash shows logo then opens watchlist', (WidgetTester tester) async {
    await tester.pumpWidget(const TradingApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('My Stocks (4)'), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);

    await tester.tap(find.text('Market'));
    await tester.pumpAndSettle();
    expect(find.text('Top Gainer: INFY  +1.72%'), findsOneWidget);

    await tester.tap(find.text('Holdings'));
    await tester.pumpAndSettle();
    expect(find.text('₹5,59,000'), findsOneWidget);

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('ITC'), findsOneWidget);
  });
}
