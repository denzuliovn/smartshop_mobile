import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/features/products/presentation/widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/cart/presentation/widgets/cart_icon_widget.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredProductsAsync = ref.watch(featuredProductsProvider);
    final forYouProductsAsync = ref.watch(latestProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: RefreshIndicator(
        // --- SỬA LẠI HÀM NÀY ---
        onRefresh: () async {
          // Dùng await để đợi, không dùng return
          await Future.wait([
            ref.refresh(featuredProductsProvider.future),
            ref.refresh(latestProductsProvider.future),
            ref.refresh(categoriesProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(context),
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Danh mục', () {
                context.go('/explore');
              }),
              const SizedBox(height: 8),

              categoriesAsync.when(
                data: (categories) => _buildCategories(categories),
                loading: () => _buildLoadingIndicator(height: 110),
                error: (err, stack) => _buildErrorWidget(err.toString(), height: 110),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Sản phẩm nổi bật', () {
                context.push('/products?featured=true');
              }),
              const SizedBox(height: 8),
              featuredProductsAsync.when(
                data: (products) => _buildHorizontalProductList(products),
                loading: () => _buildLoadingIndicator(height: 290),
                error: (err, stack) => _buildErrorWidget(err.toString(), height: 290),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Dành cho bạn', () {
                context.push('/products');
              }),
              const SizedBox(height: 8),
              forYouProductsAsync.when(
                data: (products) => _buildForYouProductsGrid(context, products),
                loading: () => _buildLoadingIndicator(isGrid: true),
                error: (err, stack) => _buildErrorWidget(err.toString()),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(24.0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Siêu Sale Tháng 7',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Giảm giá đến 50% cho tất cả sản phẩm',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withAlpha(230),
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Mua ngay'),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          TextButton(
            onPressed: onViewAll,
            child: Row(
              children: [
                Text('Xem tất cả', style: TextStyle(color: Theme.of(context).primaryColor)),
                Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(List<Category> categories) {
    
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          // Kiểm tra và tạo URL đầy đủ
          final imageUrl = (category.imageUrl != null && category.imageUrl!.startsWith('/'))
              ? "${ApiConstants.baseUrl}${category.imageUrl}"
              : category.imageUrl;


          return SizedBox(
            width: 80,
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(25),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl ?? '',
                    color: Colors.blue.shade700,
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
                    placeholder: (context, url) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHorizontalProductList(List<Product> products) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 290,
        child: Center(child: Text('Không có sản phẩm nào.')),
      );
    }
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 180,
            child: ProductCard(product: products[index]),
          );
        },
      ),
    );
  }
  
  Widget _buildLoadingIndicator({double height = 290, bool isGrid = false}) {
    if (isGrid) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(4, (index) => const Card(child: Center(child: CircularProgressIndicator()))),
      );
    }
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget(String error, {double height = 290}) {
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Lỗi: $error",
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildForYouProductsGrid(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('Không có sản phẩm nào.'),
      ));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}