// FILE PATH: lib/features/admin/presentation/screens/admin_taxonomy_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/features/admin/data/admin_repository.dart';

class AdminTaxonomyScreen extends ConsumerWidget {
  const AdminTaxonomyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final brandsAsync = ref.watch(brandsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh mục & Thương hiệu'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Danh mục'),
              Tab(text: 'Thương hiệu'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Danh mục
            categoriesAsync.when(
              data: (items) => _buildListView<Category>(context, ref, items),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Lỗi: $e')),
            ),
            // Tab Thương hiệu
            brandsAsync.when(
              data: (items) => _buildListView<Brand>(context, ref, items),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Lỗi: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView<T>(BuildContext context, WidgetRef ref, List<T> items) {
    return RefreshIndicator(
      onRefresh: () async {
        if (T == Category) ref.refresh(categoriesProvider);
        if (T == Brand) ref.refresh(brandsProvider);
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          String name = '';
          String id = '';

          if (item is Category) {
            name = item.name;
            id = item.id;
          }
          if (item is Brand) {
            name = item.name;
            id = item.id;
          }

          return ListTile(
            title: Text(name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    if (item is Category) {
                      context.push('/admin/categories/edit', extra: item);
                    }
                    if (item is Brand) {
                      context.push('/admin/brands/edit', extra: item);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Xác nhận xóa'),
                        content: Text('Bạn có chắc muốn xóa "$name"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
                        ],
                      ),
                    ) ?? false;

                    if (confirm) {
                      try {
                        if (item is Category) {
                          await ref.read(adminRepositoryProvider).deleteCategory(id);
                          ref.refresh(categoriesProvider);
                        }
                        if (item is Brand) {
                          await ref.read(adminRepositoryProvider).deleteBrand(id);
                          ref.refresh(brandsProvider);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa "$name" thành công.'), backgroundColor: Colors.green));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}