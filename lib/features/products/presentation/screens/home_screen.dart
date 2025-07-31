import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/cart/presentation/widgets/cart_icon_widget.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/features/products/presentation/widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  Timer? _bannerTimer;
  
  final List<Map<String, String>> _bannerData = [
    {
      'title': 'iPhone 15 Pro Max',
      'subtitle': 'Khung Titan. Mạnh mẽ. Đẳng cấp.',
      'image': 'https://images.unsplash.com/photo-1695823018812-c684c980ede6?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'cta': 'Mua ngay',
    },
    {
      'title': 'Siêu Sale Laptop',
      'subtitle': 'Giảm giá đến 30% cho dòng MacBook',
      'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=1200',
      'cta': 'Xem ngay',
    },
    {
      'title': 'Âm thanh Đỉnh cao',
      'subtitle': 'Tai nghe chống ồn thế hệ mới',
      'image': 'https://images.unsplash.com/photo-1558590987-ed99c5b46f6a?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'cta': 'Khám phá',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentBannerPage < _bannerData.length - 1) {
        _currentBannerPage++;
      } else {
        _currentBannerPage = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredProductsAsync = ref.watch(featuredProductsProvider);
    final forYouProductsAsync = ref.watch(latestProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
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
              _buildBannerSlider(context),
              const SizedBox(height: 24),
              
              _buildSectionHeader(context, 'Danh mục', () => context.push('/categories')),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) => _buildCategories(categories),
                loading: () => _buildLoadingIndicator(height: 110),
                error: (err, stack) => _buildErrorWidget(err.toString(), height: 110),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Sản phẩm nổi bật', () => context.push('/products?featured=true')),
              const SizedBox(height: 8),
              featuredProductsAsync.when(
                data: (products) => _buildHorizontalProductList(products),
                loading: () => _buildLoadingIndicator(height: 290),
                error: (err, stack) => _buildErrorWidget(err.toString(), height: 290),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Dành cho bạn', () => context.push('/products')),
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

  Widget _buildBannerSlider(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(top: 16),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _bannerData.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerPage = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _bannerData[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(banner['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner['title']!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                          ),
                        ),
                        Text(
                          banner['subtitle']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerData.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _currentBannerPage == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _currentBannerPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
          ),
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
    const String baseUrl = ApiConstants.baseUrl; 
    
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final imageUrl = (category.imageUrl != null && category.imageUrl!.startsWith('/'))
              ? "$baseUrl${category.imageUrl}"
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
      return const SizedBox(height: 290, child: Center(child: Text('Không có sản phẩm nào.')));
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