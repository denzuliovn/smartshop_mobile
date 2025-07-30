import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:smartshop_mobile/features/admin/application/admin_providers.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(allOrdersProvider.future),
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return const Center(child: Text('Không có đơn hàng nào.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(context, orders[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* TODO: Điều hướng đến trang tạo đơn hàng */ },
        child: const Icon(Icons.add),
        tooltip: 'Tạo đơn hàng mới',
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    Color statusColor;
    switch(order.status) {
      case 'delivered': statusColor = Colors.green; break;
      case 'shipping': statusColor = Colors.orange; break;
      case 'cancelled': statusColor = Colors.red; break;
      default: statusColor = Colors.blue;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.receipt_long, color: statusColor),
        ),
        title: Text(
          '#${order.orderNumber}', 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khách hàng: ${order.items.isNotEmpty ? "Khách hàng A" : "N/A"}'), // Placeholder
            Text('Ngày đặt: ${AppFormatters.formatDate(order.orderDate)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.currency.format(order.totalAmount), 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            Text(
              '${order.items.length} SP',
              style: const TextStyle(color: Colors.grey, fontSize: 12)
            ),
          ],
        ),
        onTap: () {
          // TODO: Điều hướng đến trang chi tiết đơn hàng của Admin
        },
      ),
    );
  }
}