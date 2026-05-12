import 'package:flutter/material.dart';

import 'features/search/presentation/mvp_screens.dart';

class TapovanaApp extends StatelessWidget {
  const TapovanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapovana',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.sage,
          primary: AppColors.sage,
          secondary: AppColors.sky,
          background: AppColors.cream,
        ),
        scaffoldBackgroundColor: AppColors.cream,
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: AppColors.charcoal),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.charcoal,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
