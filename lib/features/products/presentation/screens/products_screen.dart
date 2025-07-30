import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/filter_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/widgets/product_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final bool isFeaturedOnly;
  const ProductsScreen({super.key, this.isFeaturedOnly = false});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late ProductListFilter _filter;
  // --- THÊM LẠI KHAI BÁO NÀY ---
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filter = ProductListFilter(
      condition: widget.isFeaturedOnly ? {'isFeatured': true} : {},
      orderBy: 'CREATED_DESC',
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFeaturedOnly ? 'Sản phẩm nổi bật' : 'Tất cả Sản phẩm'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: "Sắp xếp",
            onSelected: (String value) {
              setState(() {
                _filter = _filter.copyWith(orderBy: value, page: 1);
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              _buildSortMenuItem('CREATED_DESC', 'Mới nhất', _filter.orderBy),
              _buildSortMenuItem('CREATED_ASC', 'Cũ nhất', _filter.orderBy),
              _buildSortMenuItem('PRICE_ASC', 'Giá: Thấp đến Cao', _filter.orderBy),
              _buildSortMenuItem('PRICE_DESC', 'Giá: Cao đến Thấp', _filter.orderBy),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: "Lọc sản phẩm",
            onPressed: () async {
              final newFilter = await context.push<ProductListFilter>(
                '/filter',
                extra: _filter,
              );
              
              if (newFilter != null) {
                setState(() {
                  _filter = newFilter;
                });
              }
            },
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(productsProvider(_filter)),
              child: ListView(children: const [Center(child: Text('Không có sản phẩm nào phù hợp.'))]),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(productsProvider(_filter)),
            // --- SỬA LẠI LỜI GỌI HÀM NÀY ---
            child: _buildGridView(products, false), // Tạm thời isLoadingMore là false
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String text, String? currentValue) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          if (value == currentValue)
            const Icon(Icons.check, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildGridView(List<dynamic> products, bool isLoadingMore) {
    return GridView.builder(
      controller: _scrollController, // Sử dụng scroll controller
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return ProductCard(product: products[index]);
      },
    );
  }
}