import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản của tôi')),
      body: ListView(
        children: [
          // User Info Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(mockUser.avatarUrl),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${mockUser.firstName} ${mockUser.lastName}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    Text(
                      mockUser.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu List
          _buildMenuItem(context, icon: Icons.shopping_bag_outlined, title: 'Đơn hàng của tôi', onTap: () => context.go('/orders')),
          _buildMenuItem(context, icon: Icons.location_on_outlined, title: 'Địa chỉ nhận hàng', onTap: () {}),
          _buildMenuItem(context, icon: Icons.payment_outlined, title: 'Phương thức thanh toán', onTap: () {}),
          _buildMenuItem(context, icon: Icons.notifications_outlined, title: 'Thông báo', onTap: () {}),
          _buildMenuItem(context, icon: Icons.settings_outlined, title: 'Cài đặt', onTap: () {}),
          const Divider(),
          _buildMenuItem(context, icon: Icons.logout, title: 'Đăng xuất', color: Colors.red, onTap: () => context.go('/login')),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, Color? color, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}