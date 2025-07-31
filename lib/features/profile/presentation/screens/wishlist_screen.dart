import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/features/products/presentation/widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- DÒNG BỊ THIẾU ĐÃ ĐƯỢC THÊM VÀO ĐÂY ---
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách yêu thích'),
      ),
      body: wishlistAsync.when(
        data: (wishlist) {
          if (wishlist.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Danh sách yêu thích của bạn trống', style: TextStyle(fontSize: 18)),
                   SizedBox(height: 8),
                  Text('Hãy nhấn ❤️ trên sản phẩm để thêm vào đây nhé!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(wishlistProvider.notifier).loadWishlist(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                return ProductCard(product: wishlist[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}