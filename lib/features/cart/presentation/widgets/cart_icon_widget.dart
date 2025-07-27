import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/cart/application/cart_provider.dart';

class CartIconWidget extends ConsumerWidget {
  const CartIconWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final itemCount = cartState.valueOrNull?.totalItems ?? 0;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () => context.push('/cart'),
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
        if (itemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$itemCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}