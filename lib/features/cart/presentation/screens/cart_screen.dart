import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smartshop_mobile/core/mock_data/mock_data.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  double get subtotal {
    return mockCartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: mockCartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: mockCartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = mockCartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),
                _buildSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
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

  Widget _buildCartItem(dynamic item) {
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
                  formatCurrency.format(item.product.price),
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Quantity controls
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () {
                setState(() {
                  if(item.quantity > 1) item.quantity--;
                });
              }),
              Text(item.quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {
                 setState(() {
                   if(item.quantity < item.product.stock) item.quantity++;
                });
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tạm tính', style: Theme.of(context).textTheme.titleMedium),
              Text(formatCurrency.format(subtotal), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/checkout'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('Tiến hành thanh toán'),
          ),
        ],
      ),
    );
  }
}