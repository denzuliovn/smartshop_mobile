import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/features/cart/application/cart_provider.dart';
import 'package:smartshop_mobile/features/products/presentation/widgets/review_list.dart'; // Vẫn import file này
import 'package:collection/collection.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> with SingleTickerProviderStateMixin {
  int _quantity = 1;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  // HÀM HELPER ĐỂ TẠO URL HÌNH ẢNH AN TOÀN
  String _getImageUrl(String? imagePath) {
    const String baseUrl = ApiConstants.baseUrl; // Thay bằng IP LAN nếu dùng máy thật
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/400'; // Một URL ảnh mặc định
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return "$baseUrl$imagePath";
  }

  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      body: productAsyncValue.when(
        data: (product) => _buildProductUI(context, product),
        loading: () => _buildLoadingUI(),
        error: (err, stack) => _buildErrorUI(err.toString()),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return const Center(child: CircularProgressIndicator());
  }
  
  Widget _buildErrorUI(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text('Lỗi tải sản phẩm', style: Theme.of(context).textTheme.headlineSmall),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () => ref.refresh(productDetailProvider(widget.productId)),
            child: const Text('Thử lại'),
          )
        ],
      ),
    );
  }
  
  Widget _buildProductUI(BuildContext context, Product product) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 400.0,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: product.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final imageUrl = _getImageUrl(product.images[index]);
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: product.images.map((url) {
                          int index = product.images.indexOf(url);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentImageIndex == index ? 24.0 : 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentImageIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.white.withAlpha(178),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          formatCurrency.format(product.price),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        if (product.originalPrice != null &&
                            product.originalPrice! > product.price)
                          Text(
                            formatCurrency.format(product.originalPrice),
                            style: const TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Số lượng',
                            style: Theme.of(context).textTheme.titleLarge),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                              ),
                              Text('$_quantity',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  if (_quantity < product.stock) {
                                    setState(() => _quantity++);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Mô tả'),
                    Tab(text: 'Đánh giá'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Text(product.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
            ),
            ReviewList(productId: product.id),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            label: product.stock > 0
                ? const Text('Thêm vào giỏ hàng')
                : const Text('Hết hàng'),
            onPressed: product.stock > 0
                ? () {
                    ref.read(cartProvider.notifier).addToCart(product.id, _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm $_quantity ${product.name} vào giỏ hàng!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                : null,
            style: product.stock > 0
                ? null
                : ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}