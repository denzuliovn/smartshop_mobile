import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:smartshop_mobile/features/profile/application/order_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/features/profile/data/order_repository.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderNumber;
  const OrderDetailScreen({super.key, required this.orderNumber});

  // Hàm xử lý hủy đơn
  void _handleCancelOrder(BuildContext context, WidgetRef ref) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận hủy'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final messenger = ScaffoldMessenger.of(context); // Lưu lại messenger
      try {
        await ref.read(orderRepositoryProvider).cancelOrder(orderNumber);
        ref.refresh(myOrdersProvider);
        ref.refresh(orderDetailProvider(orderNumber));
        messenger.showSnackBar(
          const SnackBar(content: Text('Đã hủy đơn hàng thành công'), backgroundColor: Colors.green),
        );
      } catch (e) {
         messenger.showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsyncValue = ref.watch(orderDetailProvider(orderNumber));

    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết đơn #$orderNumber')),
      body: orderAsyncValue.when(
        data: (order) {
          final canCancel = order.status == 'pending' || order.status == 'confirmed';
          
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
                        ? CachedNetworkImage(imageUrl: "http://192.168.1.3${item.product!.images[0]}", width: 50, errorWidget: (c,u,e) => const Icon(Icons.error))
                        : const Icon(Icons.image_not_supported),
                     title: Text(item.productName),
                     subtitle: Text('Số lượng: ${item.quantity}'),
                     trailing: Text(AppFormatters.currency.format(item.priceAtOrder * item.quantity)),
                   ),
                 ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(AppFormatters.currency.format(order.totalAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 32),
                if (canCancel)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Hủy đơn hàng'),
                      onPressed: () => _handleCancelOrder(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
             ],
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: ${err.toString()}')),
      ),
    );
  }
}