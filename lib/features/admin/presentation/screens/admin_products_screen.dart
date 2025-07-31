import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/admin/application/admin_providers.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';
import 'package:smartshop_mobile/features/admin/data/admin_repository.dart';

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
                return _buildProductListItem(context, ref, products[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/products/create'),
        child: const Icon(Icons.add),
        tooltip: 'Thêm sản phẩm',
      ),
    );
  }

  Widget _buildProductListItem(BuildContext context, WidgetRef ref, Product product) {
    String getImageUrl(String? imagePath) {
      if (imagePath == null || imagePath.isEmpty) return '';
      if (imagePath.startsWith('http')) return imagePath;
      if (imagePath.startsWith('/')) return "${ApiConstants.baseUrl}$imagePath";
      return "${ApiConstants.baseUrl}/img/$imagePath";
    }

    final imageUrl = product.images.isNotEmpty ? getImageUrl(product.images[0]) : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 80, height: 80, fit: BoxFit.cover,
                errorWidget: (c, u, e) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
                placeholder: (c, u) => Container(width: 80, height: 80, color: Colors.grey[200]),
              ),
            ),
            const SizedBox(width: 16),
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
            
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push('/admin/products/edit/${product.id}');
                } else if (value == 'delete') {
                  // --- LOGIC XÓA SẢN PHẨM ---
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: Text('Bạn có chắc muốn xóa sản phẩm "${product.name}"? Hành động này không thể hoàn tác.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
                      ],
                    ),
                  ) ?? false;
                  
                  if (confirm) {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await ref.read(adminRepositoryProvider).deleteProduct(product.id);
                      ref.refresh(adminProductsProvider); // Làm mới danh sách
                      messenger.showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm thành công!'), backgroundColor: Colors.green));
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Sửa')),
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