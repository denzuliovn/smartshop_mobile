import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/cart/presentation/widgets/cart_icon_widget.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Hàm để tính toán index của BottomNavBar dựa trên đường dẫn URL
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/explore')) {
      return 1;
    }
    if (location.startsWith('/my-orders')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0; // Mặc định là trang chủ
  }

  // Hàm để điều hướng khi bấm vào một item trên BottomNavBar
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/my-orders');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    // Quyết định AppBar nào sẽ được hiển thị dựa trên tab đang được chọn
    AppBar? buildAppBar() {
      switch (selectedIndex) {
        case 0: // Trang chủ
          return AppBar(
            title: const Text('SmartShop'),
            centerTitle: false,
            actions: [
              IconButton(onPressed: () => context.push('/search'), icon: const Icon(Icons.search)),
              const CartIconWidget(),
            ],
          );
        case 1: // Khám phá
          return AppBar(
            title: const Text('Khám phá'),
            actions: [ const CartIconWidget() ],
          );
        case 2: // Đơn hàng
          return AppBar(
            title: const Text('Đơn hàng của tôi'),
          );
        case 3: // Tài khoản
          return null;
        default:
          return null; // Không hiển thị AppBar cho các trường hợp khác
      }
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: widget.child, // Hiển thị màn hình con được truyền từ router
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}