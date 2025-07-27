import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';
import 'package:smartshop_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:smartshop_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:smartshop_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:smartshop_mobile/features/cart/presentation/screens/cart_screen.dart';
import 'package:smartshop_mobile/features/cart/presentation/screens/checkout_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/brands_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/categories_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/home_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/main_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/product_detail_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/order_detail_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/orders_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:smartshop_mobile/features/cart/presentation/screens/order_success_screen.dart';
import 'dart:async';


class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    routes: [
      // --- SỬA LẠI SHELLROUTE Ở ĐÂY ---
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(), // Key riêng cho các tab
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          // Route con không bắt đầu bằng dấu '/'
          GoRoute(
            path: '/', 
            builder: (context, state) => const HomeScreen()
          ),
          GoRoute(
            path: '/categories', 
            builder: (context, state) => const CategoriesScreen()
          ),
          GoRoute(
            path: '/brands', 
            builder: (context, state) => const BrandsScreen()
          ),
          GoRoute(
            path: '/profile', // SỬA: Bỏ dấu '/' ở đầu, nhưng vẫn giữ để điều hướng
            builder: (context, state) => const ProfileScreen()
          ),
        ],
      ),
      
      // Các route không có BottomNavBar sẽ nằm ngoài ShellRoute
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
      GoRoute(
        path: '/orders/:orderNumber',
        builder: (context, state) {
          final orderNumber = state.pathParameters['orderNumber']!;
          return OrderDetailScreen(orderNumber: orderNumber);
        },
      ),
      GoRoute(
      path: '/order-success/:orderNumber',
      builder: (context, state) {
        final orderNumber = state.pathParameters['orderNumber']!;
        return OrderSuccessScreen(orderNumber: orderNumber);
      },
      ),

    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState is Authenticated;
      final loggingIn = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register' || 
                        state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !loggingIn) return '/login';
      if (isLoggedIn && loggingIn) return '/';
      
      return null;
    },
  );
});