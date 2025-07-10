import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:smartshop_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:smartshop_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:smartshop_mobile/features/cart/presentation/screens/cart_screen.dart';
import 'package:smartshop_mobile/features/cart/presentation/screens/checkout_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/main_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/product_detail_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/order_detail_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/orders_screen.dart';

// Key để giữ state của BottomNavigationBar
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Route chính chứa BottomNavBar
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    
    // Các route không có BottomNavBar
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersScreen(),
    ),
    GoRoute(
      path: '/orders/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),
  ],
);