import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/core/utils/icon_mapper.dart';
import 'package:smartshop_mobile/features/products/presentation/widgets/product_card.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final brandsAsync = ref.watch(brandsProvider);
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      // AppBar đã được quản lý bởi MainScreen
      body: RefreshIndicator(
        onRefresh: () async {
          // Làm mới tất cả các provider trên trang này
          ref.refresh(categoriesProvider);
          ref.refresh(brandsProvider);
          ref.refresh(wishlistProvider.notifier).loadWishlist();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            // 1. Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () => context.push('/search'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text('Tìm kiếm sản phẩm...', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Danh mục
            _buildSectionHeader(context, 'Danh mục sản phẩm', () => context.push('/categories')),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return InkWell(
                    onTap: () => context.push('/products?categoryId=${category.id}'),
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(IconMapper.getCategoryIcon(category.name), size: 28, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(category.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Padding(padding: const EdgeInsets.all(16), child: Text('Lỗi tải danh mục: $err')),
            ),
            const SizedBox(height: 24),
            
            // 3. Thương hiệu
            _buildSectionHeader(context, 'Thương hiệu nổi bật', () => context.push('/brands')),
            const SizedBox(height: 16),
            brandsAsync.when(
              data: (brands) => SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: brands.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    return Card(
                      child: InkWell(
                        onTap: () => context.push('/products?brandId=${brand.id}'),
                        child: SizedBox(
                          width: 120,
                          child: Center(child: Icon(IconMapper.getBrandIcon(brand.name), size: 40, color: Colors.grey[800])),
                        ),
                      ),
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Padding(padding: const EdgeInsets.all(16), child: Text('Lỗi tải thương hiệu: $err')),
            ),
            const SizedBox(height: 24),

            // 4. Wishlist
            _buildSectionHeader(context, 'Yêu thích', () => context.push('/wishlist')),
            const SizedBox(height: 16),
            wishlistAsync.when(
              data: (wishlist) {
                if (wishlist.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('Chưa có sản phẩm yêu thích.')),
                    ),
                  );
                }
                return SizedBox(
                  height: 290,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: wishlist.length > 5 ? 5 : wishlist.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 180,
                        child: ProductCard(product: wishlist[index]),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 290,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SizedBox(
                height: 290,
                child: Center(child: Text('Lỗi tải Wishlist: $err')),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          TextButton(onPressed: onViewAll, child: const Text('Xem tất cả')),
        ],
      ),
    );
  }
}