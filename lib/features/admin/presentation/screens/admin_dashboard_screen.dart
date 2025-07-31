import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:smartshop_mobile/features/admin/application/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(orderStatsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(orderStatsProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text(
                'Chào mừng đến với Bảng điều khiển!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Stats Cards
            statsAsync.when(
              data: (stats) => GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2, // Tăng chiều cao của card
                ),
                children: [
                  _buildStatCard(context, 'Tổng Đơn', stats.totalOrders.toString(), Icons.shopping_bag_outlined),
                  _buildStatCard(context, 'Đơn Chờ', stats.pendingOrders.toString(), Icons.pending_actions_outlined, color: Colors.orange),
                  _buildStatCard(context, 'Hoàn thành', stats.deliveredOrders.toString(), Icons.check_circle_outline, color: Colors.green),
                  _buildStatCard(context, 'Doanh thu', AppFormatters.currency.format(stats.totalRevenue), Icons.attach_money, color: Colors.teal),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),

            // More sections to be added...
          ],
        ),
      ),
    );
  }

  // --- WIDGET ĐÃ ĐƯỢC THIẾT KẾ LẠI ---
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, {Color color = const Color.fromARGB(255, 101, 15, 193)}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 22, color: color),
            ),
            const Spacer(),
            
            // Value
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.2, // Giảm khoảng cách dòng
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Title
            Text(
              title,
              style: const TextStyle(color: Colors.grey, height: 1.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}