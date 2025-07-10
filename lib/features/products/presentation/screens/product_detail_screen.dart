// lib/features/products/presentation/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:smartshop_mobile/core/mock_data/mock_data.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:collection/collection.dart'; // Import package collection

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // Tìm sản phẩm trong mock data dựa vào ID
    final product = mockProducts.firstWhereOrNull((p) => p.id == widget.productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy sản phẩm!')),
      );
    }

    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- App Bar với ảnh sản phẩm ---
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
                      return CachedNetworkImage(
                        imageUrl: product.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      );
                    },
                  ),
                  // Dấu chấm chỉ vị trí ảnh
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: product.images.map((url) {
                        int index = product.images.indexOf(url);
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Nội dung chi tiết ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Giá sản phẩm
                  Row(
                    children: [
                      Text(
                        formatCurrency.format(product.price),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      if (product.originalPrice != null && product.originalPrice! > product.price)
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

                  // Mô tả
                  Text(
                    'Mô tả sản phẩm',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Chọn số lượng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Số lượng', style: Theme.of(context).textTheme.titleLarge),
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
                            Text('$_quantity', style: const TextStyle(fontSize: 18)),
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
          )
        ],
      ),
      // --- Nút thêm vào giỏ hàng ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Thêm vào giỏ hàng'),
          onPressed: product.stock > 0 ? () {
            // TODO: Add to cart logic
          } : null,
        ),
      ),
    );
  }
}