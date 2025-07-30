import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/admin/data/admin_repository.dart';

final orderStatsProvider = FutureProvider.autoDispose<OrderStats>((ref) {
  return ref.watch(adminRepositoryProvider).getOrderStats();
});

final allOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  // Tạm thời chưa có phân trang và lọc
  return ref.watch(adminRepositoryProvider).getAllOrders();
});

final adminOrderDetailProvider = FutureProvider.autoDispose.family<Order, String>((ref, orderNumber) {
  return ref.watch(adminRepositoryProvider).getOrder(orderNumber);
});

