import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/admin/application/admin_providers.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart'; 

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminProductsProvider.future),
        child: productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('Không có sản phẩm nào.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductListItem(context, products[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* TODO: Navigate to create product screen */ },
        child: const Icon(Icons.add),
        tooltip: 'Thêm sản phẩm',
      ),
    );
  }

  Widget _buildProductListItem(BuildContext context, Product product) {
    // --- SỬ DỤNG ApiConstants.baseUrl ĐỂ TẠO URL AN TOÀN ---
    final imageUrl = product.images.isNotEmpty
        ? "${ApiConstants.baseUrl}${product.images[0]}"
        : ''; // Để trống nếu không có ảnh

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                // Widget hiển thị khi có lỗi hoặc URL rỗng
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
                // Widget hiển thị khi đang tải
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Kho: ${product.stock}', style: TextStyle(color: product.stock > 0 ? Colors.green.shade700 : Colors.red.shade700, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.currency.format(product.price),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // TODO: Navigate to edit screen
                } else if (value == 'delete') {
                  // TODO: Handle delete
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(leading: Icon(Icons.edit), title: Text('Sửa')),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Xóa', style: TextStyle(color: Colors.red))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}