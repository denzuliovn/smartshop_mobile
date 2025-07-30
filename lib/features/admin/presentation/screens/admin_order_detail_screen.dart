import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/features/admin/application/admin_providers.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';

class AdminOrderDetailScreen extends ConsumerWidget {
  final String orderNumber;
  const AdminOrderDetailScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(adminOrderDetailProvider(orderNumber));

    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết Đơn #$orderNumber')),
      body: orderAsync.when(
        data: (order) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // TODO: Hiển thị chi tiết thông tin khách hàng, sản phẩm, các nút hành động...
            Text('Thông tin khách hàng:', style: Theme.of(context).textTheme.titleLarge),
            Text('Tên: ${order.items.isNotEmpty ? "Khách hàng A" : "N/A"}'),
            const Divider(height: 32),
            Text('Sản phẩm:', style: Theme.of(context).textTheme.titleLarge),
            for (var item in order.items)
              ListTile(
                title: Text(item.productName),
                trailing: Text(AppFormatters.currency.format(item.priceAtOrder * item.quantity)),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}