import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart' as model;
import 'package:smartshop_mobile/features/cart/application/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: cartState.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(context, ref, item, formatCurrency);
                  },
                ),
              ),
              _buildSummary(context, cart, formatCurrency),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải giỏ hàng: ${err.toString()}')),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text('Giỏ hàng của bạn trống', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text('Hãy thêm sản phẩm để mua sắm nhé!', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Tiếp tục mua sắm'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, model.CartItem item, NumberFormat formatCurrency) {
     return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: item.product.images[0],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(
                  formatCurrency.format(item.unitPrice),
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () {
                if(item.quantity > 1) {
                  ref.read(cartProvider.notifier).updateItem(item.product.id, item.quantity - 1);
                } else {
                   ref.read(cartProvider.notifier).removeItem(item.product.id);
                }
              }),
              Text(item.quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {
                if(item.quantity < item.product.stock) {
                   ref.read(cartProvider.notifier).updateItem(item.product.id, item.quantity + 1);
                }
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, model.Cart cart, NumberFormat formatCurrency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), spreadRadius: 0, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tạm tính (${cart.totalItems})', style: Theme.of(context).textTheme.titleMedium),
              Text(formatCurrency.format(cart.subtotal), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/checkout'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('Tiến hành thanh toán'),
          ),
        ],
      ),
    );
  }
}