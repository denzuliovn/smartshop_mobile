import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smartshop_mobile/features/profile/application/order_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderNumber; // Giữ lại id để tương thích với router hiện tại
  const OrderDetailScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Giả sử orderNumber và orderId giống nhau trong mock, cần sửa lại khi có API
    final orderAsyncValue = ref.watch(orderDetailProvider(orderNumber));

    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết đơn #$orderNumber')),
      body: orderAsyncValue.when(
        data: (order) {
          final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
          return ListView(
             padding: const EdgeInsets.all(16),
             children: [
               Text('Danh sách sản phẩm', style: Theme.of(context).textTheme.titleLarge),
               const SizedBox(height: 12),
               for(var item in order.items)
                 Card(
                   margin: const EdgeInsets.only(bottom: 12),
                   child: ListTile(
                     leading: item.product?.images.isNotEmpty ?? false
                        ? CachedNetworkImage(imageUrl: item.product!.images[0], width: 50)
                        : const Icon(Icons.image_not_supported),
                     title: Text(item.productName),
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
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: ${err.toString()}')),
      ),
    );
  }
}