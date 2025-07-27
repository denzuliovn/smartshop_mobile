import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';
import 'package:smartshop_mobile/features/cart/data/cart_repository.dart';

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<Cart>>((ref) {
  final authState = ref.watch(authProvider);
  // Chỉ tạo Notifier có khả năng tải dữ liệu khi đã đăng nhập
  if (authState is Authenticated) {
    return CartNotifier(ref)..loadCart();
  }
  // Nếu chưa đăng nhập, trả về Notifier với giỏ hàng rỗng
  return CartNotifier(ref);
});

class CartNotifier extends StateNotifier<AsyncValue<Cart>> {
  final Ref _ref;

  CartNotifier(this._ref) : super(AsyncData(Cart.empty()));

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    try {
      final cart = await _ref.read(cartRepositoryProvider).getCart();
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      await _ref.read(cartRepositoryProvider).addToCart(productId, quantity);
      await loadCart(); // Tải lại giỏ hàng để cập nhật UI
    } catch (e) {
      // Có thể hiển thị lỗi ở đây
    }
  }

  Future<void> updateItem(String productId, int quantity) async {
    // Không cần set loading để UI không bị giật khi bấm +/-
    try {
      await _ref.read(cartRepositoryProvider).updateCartItem(productId, quantity);
      await loadCart();
    } catch (e) {
      // Có thể xử lý lỗi và quay lại trạng thái cũ
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      await _ref.read(cartRepositoryProvider).removeFromCart(productId);
      await loadCart();
    } catch(e) {
      //...
    }
  }
}