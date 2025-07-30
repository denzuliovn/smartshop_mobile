import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:smartshop_mobile/features/profile/application/order_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(myOrdersProvider);

    return Scaffold(
      // --- XÓA BỎ AppBar Ở ĐÂY ---
      // appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      
      // Phần body giữ nguyên
      body: ordersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa có đơn hàng nào', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Bắt đầu mua sắm'),
                  )
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(myOrdersProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildOrderCard(context, orders[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: ${err.toString()}')),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    Color statusColor;
    String statusText;
    switch (order.status) {
      case 'delivered':
        statusColor = Colors.green;
        statusText = 'Đã giao hàng';
        break;
      case 'shipping':
        statusColor = Colors.orange;
        statusText = 'Đang vận chuyển';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Đang xử lý';
    }

    return Card(
      child: InkWell(
        onTap: () => context.push('/orders/${order.orderNumber}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Đơn hàng #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(AppFormatters.formatDate(order.orderDate), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Số lượng: ${order.items.length} sản phẩm'),
                  Text('Tổng tiền: ${AppFormatters.currency.format(order.totalAmount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => context.push('/orders/${order.orderNumber}'),
                    child: const Text('Xem chi tiết'),
                  ),
                  Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}