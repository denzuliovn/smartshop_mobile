import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Nếu user chưa đăng nhập
    if (authState is! Authenticated) {
      return Center(
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
      );
    }
    
    // Nếu đã đăng nhập, hiển thị thông tin
    final user = authState.user;

    return Scaffold(
      // AppBar đã được quản lý bởi MainScreen
      body: ListView(
        padding: EdgeInsets.zero, // Xóa padding mặc định của ListView
        children: [
          // User Info Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24), // Tăng padding top
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  // Kiểm tra xem avatarUrl có null không
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  // Nếu không có ảnh, hiển thị icon mặc định
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white70)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/edit-profile'),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Chỉnh sửa thông tin',
                ),
              ],
            ),
          ),
          
          // --- THÊM NÚT ADMIN PANEL ---
          if (user.role == 'admin' || user.role == 'manager')
             _buildMenuItem(
                context,
                icon: Icons.admin_panel_settings_outlined,
                title: 'Khu vực Quản trị',
                onTap: () => context.go('/admin'),
             ),
          
          // Menu List
          _buildMenuItem(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Đơn hàng của tôi',
            onTap: () => context.go('/my-orders'),
          ),
          _buildMenuItem(context, icon: Icons.favorite_border, title: 'Danh sách yêu thích', onTap: () => context.push('/wishlist')),
          _buildMenuItem(context, icon: Icons.location_on_outlined, title: 'Địa chỉ nhận hàng', onTap: () => context.push('/addresses')),
          _buildMenuItem(context, icon: Icons.payment_outlined, title: 'Phương thức thanh toán', onTap: () {}),
          _buildMenuItem(context, icon: Icons.notifications_outlined, title: 'Thông báo', onTap: () => context.push('/notifications')),
          _buildMenuItem(context, icon: Icons.settings_outlined, title: 'Cài đặt', onTap: () => context.push('/settings')),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Đăng xuất',
            color: Colors.red,
            onTap: () {
              ref.read(authProvider.notifier).logout();
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