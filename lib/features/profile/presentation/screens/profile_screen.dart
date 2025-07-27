import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/mock_data.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is! Authenticated) {
      // Nếu user chưa đăng nhập, hiển thị nút để đi tới trang login
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Vui lòng đăng nhập để xem thông tin.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Đăng nhập / Đăng ký'),
              )
            ],
          ),
        )
      );
    }
    
    // Nếu đã đăng nhập, hiển thị thông tin
    final user = authState.user;

    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          _buildMenuItem(context, icon: Icons.shopping_bag_outlined, title: 'Đơn hàng của tôi', onTap: () => context.push('/orders')),
          _buildMenuItem(context, icon: Icons.location_on_outlined, title: 'Địa chỉ nhận hàng', onTap: () {}),
          const Divider(),
          _buildMenuItem(
            context, 
            icon: Icons.logout, 
            title: 'Đăng xuất', 
            color: Colors.red, 
            onTap: () {
              ref.read(authProvider.notifier).logout();
              // Router sẽ tự động điều hướng về trang login nhờ redirect
            }
          ),
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