import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/features/admin/application/admin_providers.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/features/admin/presentation/widgets/update_status_dialog.dart';
import 'package:smartshop_mobile/features/admin/data/admin_repository.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';

class AdminOrderDetailScreen extends ConsumerWidget {
  final String orderNumber;
  const AdminOrderDetailScreen({super.key, required this.orderNumber});
  
  // Hàm helper để tạo URL hình ảnh an toàn
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Trả về chuỗi rỗng để errorWidget xử lý
    }
    // Nếu đã là URL đầy đủ (ví dụ: từ Firebase)
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    // Nếu là đường dẫn tương đối (bắt đầu bằng /)
    if (imagePath.startsWith('/')) {
      return "${ApiConstants.baseUrl}$imagePath";
    }
    // Mặc định, nếu chỉ là tên file
    return "${ApiConstants.baseUrl}/img/$imagePath";
  }

  void _showUpdateStatusDialog(BuildContext context, WidgetRef ref, Order order) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => UpdateStatusDialog(
        currentOrderStatus: order.status,
        currentPaymentStatus: order.paymentStatus,
      ),
    );

    if (result != null) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        bool updated = false;
        if (result['orderStatus'] != order.status) {
          await ref.read(adminRepositoryProvider).updateOrderStatus(
            orderNumber: order.orderNumber,
            status: result['orderStatus']!,
          );
          updated = true;
        }
        if (result['paymentStatus'] != order.paymentStatus) {
           await ref.read(adminRepositoryProvider).updatePaymentStatus(
            orderNumber: order.orderNumber,
            paymentStatus: result['paymentStatus']!,
          );
           updated = true;
        }

        if (updated) {
          messenger.showSnackBar(const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green));
          ref.refresh(adminOrderDetailProvider(order.orderNumber));
          ref.refresh(allOrdersProvider);
        }
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(adminOrderDetailProvider(orderNumber));

    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết Đơn #$orderNumber')),
      body: orderAsync.when(
        data: (order) => _buildOrderDetail(context, ref, order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildOrderDetail(BuildContext context, WidgetRef ref, Order order) {
    final customerName = order.customerInfo?['fullName'] ?? '${order.user?.firstName ?? ''} ${order.user?.lastName ?? ''}'.trim();
    final customerPhone = order.customerInfo?['phone'] ?? 'N/A';
    final customerAddress = order.customerInfo?['address'] ?? 'N/A';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Thông tin khách hàng ---
        _buildInfoCard(
          context,
          title: 'Khách hàng',
          icon: Icons.person_outline,
          children: [
            _buildInfoRow('Tên:', customerName),
            _buildInfoRow('Số điện thoại:', customerPhone),
            _buildInfoRow('Địa chỉ:', customerAddress),
          ],
        ),
        const SizedBox(height: 16),

        // --- Tóm tắt đơn hàng ---
        _buildInfoCard(
          context,
          title: 'Tóm tắt',
          icon: Icons.receipt_long_outlined,
          children: [
            _buildInfoRow('Mã đơn hàng:', order.orderNumber),
            _buildInfoRow('Ngày đặt:', AppFormatters.formatDate(order.orderDate)),
            _buildInfoRow('Trạng thái:', order.status.toUpperCase()),
            _buildInfoRow('Thanh toán:', order.paymentStatus.toUpperCase()),
            _buildInfoRow('Tổng tiền:', AppFormatters.currency.format(order.totalAmount), isBold: true),
          ],
        ),
        const SizedBox(height: 16),

        // --- Danh sách sản phẩm ---
        _buildInfoCard(
          context,
          title: 'Sản phẩm (${order.items.length})',
          icon: Icons.shopping_bag_outlined,
          children: [
            for (var item in order.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CachedNetworkImage(
                  imageUrl: getImageUrl(item.product?.images.isNotEmpty ?? false ? item.product!.images[0] : null),
                  width: 50, height: 50, fit: BoxFit.cover,
                  errorWidget: (c, u, e) => Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                  placeholder: (c, u) => Container(width: 50, height: 50, color: Colors.grey[200]),
                ),
                title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('SL: ${item.quantity}'),
                trailing: Text(AppFormatters.currency.format(item.priceAtOrder * item.quantity)),
              )
          ]
        ),
        const SizedBox(height: 24),
        
        // --- NÚT HÀNH ĐỘNG CỦA ADMIN ---
        ElevatedButton.icon(
          icon: const Icon(Icons.sync),
          label: const Text('Cập nhật trạng thái'),
          onPressed: () => _showUpdateStatusDialog(context, ref, order),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)
            ),
          ),
        ],
      ),
    );
  }
}