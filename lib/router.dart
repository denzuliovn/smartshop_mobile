import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';
import 'package:smartshop_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:smartshop_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:smartshop_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:smartshop_mobile/features/cart/presentation/screens/cart_screen.dart';
import 'package:smartshop_mobile/features/cart/presentation/screens/checkout_screen.dart';
import 'package:smartshop_mobile/features/cart/presentation/screens/order_success_screen.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/explore_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/home_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/main_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/product_detail_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/products_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/search_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/order_detail_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/orders_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/filter_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/address_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/notifications_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/settings_screen.dart';
import 'package:smartshop_mobile/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:smartshop_mobile/features/admin/presentation/screens/admin_main_screen.dart';
import 'package:smartshop_mobile/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:smartshop_mobile/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:smartshop_mobile/features/admin/presentation/screens/admin_order_detail_screen.dart';
import 'package:smartshop_mobile/features/admin/presentation/screens/admin_create_product_screen.dart';
import 'package:smartshop_mobile/features/admin/presentation/screens/admin_edit_product_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/write_review_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/wishlist_screen.dart';
import 'package:smartshop_mobile/features/profile/presentation/screens/add_edit_address_screen.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/admin/presentation/screens/admin_product_detail_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/all_categories_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/all_brands_screen.dart';
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

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    routes: [
      // ShellRoute sẽ "bọc" các màn hình có BottomNavBar
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
          GoRoute(path: '/my-orders', builder: (context, state) => const OrdersScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),

      ShellRoute(
        builder: (context, state, child) {
          // AdminMainScreen sẽ chứa sidebar/bottom bar của admin
          return AdminMainScreen(child: child);
        },
        routes: [
          GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/orders', builder: (context, state) => const AdminOrdersScreen()),
          GoRoute(path: '/admin/products', builder: (context, state) => const AdminProductsScreen()),
          GoRoute(
            path: '/admin/orders/:orderNumber',
            builder: (context, state) {
              final orderNumber = state.pathParameters['orderNumber']!;
              return AdminOrderDetailScreen(orderNumber: orderNumber);
            },
          ),
          GoRoute(
            path: '/admin/products/create',
            builder: (context, state) => const AdminCreateProductScreen(),
          ),
          GoRoute(
            path: '/admin/products/detail/:productId',
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return AdminProductDetailScreen(productId: productId);
            },
          ),
          GoRoute(
            path: '/admin/products/edit/:productId',
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return AdminEditProductScreen(productId: productId);
            },
          ),
        ]
      ),


      
      // Các route không có BottomNavBar sẽ nằm ngoài ShellRoute
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) {
          // Lấy tất cả các tham số từ URL
          final isFeatured = state.uri.queryParameters['featured'] == 'true';
          final categoryId = state.uri.queryParameters['categoryId'];
          final categoryName = state.uri.queryParameters['categoryName'];
          final brandId = state.uri.queryParameters['brandId'];
          final brandName = state.uri.queryParameters['brandName'];
          // final categoryId = state.uri.queryParameters['categoryId'];
          // final brandId = state.uri.queryParameters['brandId'];
          
          return ProductsScreen(
            isFeaturedOnly: isFeatured,
            categoryId: categoryId,
            categoryName: categoryName,
            brandId: brandId,
            brandName: brandName,
          );
        },
      ),

      GoRoute(
        path: '/filter',
        pageBuilder: (context, state) {
          // --- SỬA LẠI CÁCH NHẬN `extra` ---
          final initialFilter = state.extra as ProductListFilter? ?? const ProductListFilter();
          return MaterialPage(
            child: FilterScreen(initialFilter: initialFilter),
            fullscreenDialog: true,
          );
        },
      ),

      GoRoute(
        path: '/brands',
        builder: (context, state) => const AllBrandsScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const AllCategoriesScreen(),
      ),
      // GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(
        path: '/order-success/:orderNumber',
        builder: (context, state) {
          final orderNumber = state.pathParameters['orderNumber']!;
          return OrderSuccessScreen(orderNumber: orderNumber);
        },
      ),
      GoRoute(
        path: '/orders/:orderNumber',
        builder: (context, state) {
          final orderNumber = state.pathParameters['orderNumber']!;
          return OrderDetailScreen(orderNumber: orderNumber);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/product/:id/review',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return WriteReviewScreen(productId: productId);
        },
      ),
      GoRoute(path: '/wishlist', builder: (context, state) => const WishlistScreen()),

      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressScreen(),
      ),
      // ===== THÊM ROUTE MỚI VÀO ĐÂY =====
      GoRoute(
        path: '/add-edit-address',
        builder: (context, state) {
          final address = state.extra as Address?; // Nhận địa chỉ (nếu có)
          return AddEditAddressScreen(address: address);
        },
      ),

    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState is Authenticated;
      final userRole = isLoggedIn ? authState.user.role : null;
      
      final loggingIn = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register' || 
                        state.matchedLocation == '/forgot-password';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      // Nếu chưa đăng nhập và cố vào trang admin -> về login
      if (!isLoggedIn && isAdminRoute) return '/login';
      
      // Nếu đã đăng nhập nhưng không phải admin/manager và cố vào trang admin
      if (isLoggedIn && userRole == 'customer' && isAdminRoute) return '/';

      if (!isLoggedIn && !loggingIn) return '/login';
      if (isLoggedIn && loggingIn) return '/';
      
      return null;

    },
  );
});