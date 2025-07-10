import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartshop_mobile/core/mock_data/mock_data.dart';
import 'package:collection/collection.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = mockOrders.firstWhereOrNull((o) => o.id == orderId);
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    if (order == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Không tìm thấy đơn hàng')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết đơn #${order.orderNumber}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //... Hiển thị chi tiết đơn hàng (thông tin giao hàng, sản phẩm, tổng tiền, etc.)
          Text('Danh sách sản phẩm', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for(var item in order.items)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CachedNetworkImage(imageUrl: item.product.images[0], width: 50),
                title: Text(item.product.name),
                subtitle: Text('Số lượng: ${item.quantity}'),
                trailing: Text(formatCurrency.format(item.priceAtOrder * item.quantity)),
              ),
            ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(formatCurrency.format(order.totalAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}