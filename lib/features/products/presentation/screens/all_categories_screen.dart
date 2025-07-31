// FILE PATH: lib/features/products/presentation/screens/all_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/utils/icon_mapper.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';

class AllCategoriesScreen extends ConsumerWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng lại provider đã có để lấy danh sách danh mục
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả Danh mục'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Không có danh mục nào.'));
          }
          // Sử dụng GridView để hiển thị một cách trực quan
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Hiển thị 3 cột
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Tỉ lệ chiều rộng/cao của mỗi item
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              // Mỗi danh mục là một Card có thể nhấn vào
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(
                    '/products?categoryId=${category.id}&categoryName=${Uri.encodeComponent(category.name)}',
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon lớn, dễ nhìn
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(
                          IconMapper.getCategoryIcon(category.name),
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tên danh mục
                      Text(
                        category.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải danh mục: $err')),
      ),
    );
  }
}