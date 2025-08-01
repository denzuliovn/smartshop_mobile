import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminMainScreen extends StatelessWidget {
  final Widget child;
  const AdminMainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng Drawer làm sidebar
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(title: const Text('Dashboard'), onTap: () => context.go('/admin')),
            ListTile(title: const Text('Quản lý Đơn hàng'), onTap: () => context.go('/admin/orders')),
            ListTile(title: const Text('Quản lý Sản phẩm'), onTap: () => context.go('/admin/products')),
            ListTile(title: const Text('Danh mục & Thương hiệu'), onTap: () => context.go('/admin/taxonomy')),
            const Divider(),
            ListTile(title: const Text('Quay lại trang KH'), onTap: () => context.go('/')),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: child,
    );
  }
}