import 'package:flutter/material.dart';
import 'package:smartshop_mobile/core/theme/theme.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartShop',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(), // Màn hình chính của ứng dụng
    );
  }
}