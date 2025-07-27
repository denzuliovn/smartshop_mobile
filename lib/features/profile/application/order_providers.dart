import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/profile/data/order_repository.dart';

// Provider để lấy danh sách tất cả đơn hàng
final myOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).getMyOrders();
});

// Provider để lấy chi tiết một đơn hàng
final orderDetailProvider = FutureProvider.autoDispose.family<Order, String>((ref, orderNumber) {
  return ref.watch(orderRepositoryProvider).getOrderDetails(orderNumber);
});