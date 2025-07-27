import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/cart/presentation/widgets/cart_icon_widget.dart';

class MainScreen extends StatefulWidget {
  // THÊM: MainScreen giờ sẽ nhận một widget con để hiển thị
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Hàm để tính toán index của BottomNavBar dựa trên đường dẫn URL
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/categories')) {
      return 1;
    }
    if (location.startsWith('/brands')) {
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
        context.go('/categories');
        break;
      case 2:
        context.go('/brands');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar này sẽ được chia sẻ cho các màn hình con
      appBar: AppBar(
        title: const Text('SmartShop'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          const CartIconWidget(),
        ],
      ),
      // Hiển thị widget con được truyền vào từ ShellRoute
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Danh mục'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Thương hiệu'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed, // Để label luôn hiển thị
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}