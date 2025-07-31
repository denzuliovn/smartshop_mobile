import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/products/application/search_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart'; // Thêm import

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});
  
  // --- THÊM HÀM HELPER NÀY ---
  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.startsWith('/')) return "${ApiConstants.baseUrl}$imagePath";
    return "${ApiConstants.baseUrl}/img/$imagePath";
  }

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
      body: switch (searchState) {
        SearchInitial() => const Center(child: Text('Nhập từ khóa để tìm kiếm (ít nhất 3 ký tự).')),
        SearchLoading() => const Center(child: CircularProgressIndicator()),
        SearchLoaded(products: final products) => products.isEmpty
            ? const Center(child: Text('Không tìm thấy sản phẩm nào.'))
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  // --- SỬA LẠI CÁCH LẤY URL ---
                  final imageUrl = _getImageUrl(product.images.isNotEmpty ? product.images[0] : null);

                  return ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    title: Text(product.name),
                    subtitle: Text(AppFormatters.currency.format(product.price)),
                    onTap: () => context.push('/product/${product.id}'),
                  );
                },
              ),
        SearchError(message: final message) => Center(child: Text('Lỗi: $message')),
        _ => const Center(child: Text('Trạng thái không xác định.')),
      },
    );
  }
}