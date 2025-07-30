import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/products/application/search_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                searchController.clear();
                ref.read(searchProvider.notifier).clear();
              },
            ),
          ),
          onChanged: (query) {
            ref.read(searchProvider.notifier).search(query);
          },
        ),
      ),
      // --- SỬA LẠI KHỐI NÀY ---
      body: switch (searchState) {
        SearchInitial() => const Center(child: Text('Nhập từ khóa để tìm kiếm (ít nhất 3 ký tự).')),
        SearchLoading() => const Center(child: CircularProgressIndicator()),
        SearchLoaded(products: final products) => products.isEmpty
            ? const Center(child: Text('Không tìm thấy sản phẩm nào.'))
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: product.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: "http://10.0.2.2:4000${product.images[0]}",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                        )
                      : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image)),
                    title: Text(product.name),
                    subtitle: Text(AppFormatters.currency.format(product.price)),
                    onTap: () => context.push('/product/${product.id}'),
                  );
                },
              ),
        SearchError(message: final message) => Center(child: Text('Lỗi: $message')),
        // --- THÊM TRƯỜNG HỢP MẶC ĐỊNH ---
        _ => const Center(child: Text('Trạng thái không xác định.')),
      },
    );
  }
}