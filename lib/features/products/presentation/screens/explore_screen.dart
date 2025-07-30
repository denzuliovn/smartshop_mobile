import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/utils/icon_mapper.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final brandsAsync = ref.watch(brandsProvider);

    return Scaffold(
      // AppBar đã được quản lý bởi MainScreen
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Thanh tìm kiếm
          const TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // 2. Danh mục
          Text('Danh mục sản phẩm', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          categoriesAsync.when(
            data: (categories) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  child: InkWell(
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(IconMapper.getCategoryIcon(category.name), size: 36, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 8),
                        Text(category.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Lỗi: $err'),
          ),
          const SizedBox(height: 24),
          
          // 3. Thương hiệu
          Text('Thương hiệu nổi bật', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          brandsAsync.when(
            data: (brands) => SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: brands.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  return Card(
                    child: InkWell(
                      onTap: () {},
                      child: SizedBox(
                        width: 100,
                        child: Center(
                          child: Icon(IconMapper.getBrandIcon(brand.name), size: 40, color: Colors.grey[800]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Lỗi: $err'),
          ),
          const SizedBox(height: 24),

          // 4. Wishlist (Tạm thời)
          Text('Danh sách yêu thích', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Tính năng Wishlist sẽ được phát triển sau.')),
            ),
          )
        ],
      ),
    );
  }
}