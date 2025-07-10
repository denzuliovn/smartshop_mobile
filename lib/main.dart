import 'package:flutter/material.dart';
import 'package:smartshop_mobile/core/theme/theme.dart';
import 'package:smartshop_mobile/router.dart'; // Import router

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng MaterialApp.router để tích hợp GoRouter
    return MaterialApp.router(
      title: 'SmartShop',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router, // Cung cấp cấu hình router cho ứng dụng
    );
  }
}