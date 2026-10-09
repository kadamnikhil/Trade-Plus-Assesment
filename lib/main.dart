import 'package:flutter/material.dart';
import 'package:marketupdates/Constant/colors.dart';
import 'package:marketupdates/Services/market_feed.dart';
import 'package:marketupdates/Services/portfolio.dart';
import 'Designs/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MarketFeed.instance.start();
  await Portfolio.instance.load();
  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradePlus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.black,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          onPrimary: AppColors.black,
          surface: AppColors.card,
          onSurface: AppColors.text,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.gold,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: AppColors.line),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.card,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.card,
          dragHandleColor: AppColors.gold,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.black,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.goldDim,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.black,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          labelStyle: TextStyle(color: AppColors.gold),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.gold, width: 1.4),
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.card,
          selectedColor: AppColors.gold,
          labelStyle: TextStyle(color: AppColors.text),
          secondaryLabelStyle: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
          side: BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
