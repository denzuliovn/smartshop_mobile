import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smartshop_mobile/core/mock_data/mock_data.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildOrderCard(context, mockOrders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final formatDate = DateFormat('dd/MM/yyyy HH:mm');

    Color statusColor;
    String statusText;
    switch(order.status) {
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
        onTap: () => context.go('/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Đơn hàng #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(formatDate.format(order.orderDate), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Số lượng: ${order.items.length} sản phẩm'),
                  Text('Tổng tiền: ${formatCurrency.format(order.totalAmount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   OutlinedButton(
                     onPressed: () => context.go('/orders/${order.id}'),
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