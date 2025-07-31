import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/features/products/presentation/screens/filter_screen.dart';
import 'package:smartshop_mobile/features/products/presentation/widgets/product_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final bool isFeaturedOnly;
  final String? categoryId; 
  final String? categoryName;
  final String? brandId;
  final String? brandName;

  const ProductsScreen({
    super.key, 
    this.isFeaturedOnly = false,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
  });

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  // --- STATE CỤC BỘ ---
  late ProductListFilter _filter;
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];
  bool _isLoadingMore = false;
  bool _canLoadMore = true;

  @override
  void initState() {
    super.initState();
    // Cập nhật logic khởi tạo bộ lọc
    Map<String, dynamic> initialCondition = {};
    if (widget.isFeaturedOnly) {
      initialCondition['isFeatured'] = true;
    }
    if (widget.categoryId != null) {
      initialCondition['category'] = widget.categoryId;
    }
    if (widget.brandId != null) initialCondition['brand'] = widget.brandId;

    _filter = ProductListFilter(
      condition: initialCondition,
      orderBy: 'CREATED_DESC',
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore && _canLoadMore) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    setState(() => _isLoadingMore = true);
    
    final nextPageFilter = _filter.copyWith(page: _filter.page + 1);
    
    try {
      // Dùng ref.read để gọi một lần, không theo dõi
      final newProducts = await ref.read(productsProvider(nextPageFilter).future);
      if (mounted) {
        setState(() {
          _products.addAll(newProducts);
          _filter = nextPageFilter; // Cập nhật page hiện tại
          _canLoadMore = newProducts.length == _filter.limit;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    // Khi refresh, cập nhật _filter và để `ref.watch` trong build tự xử lý
    setState(() {
      _filter = _filter.copyWith(page: 1);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- LẮNG NGHE PROVIDER Ở ĐÂY ---
    final productsAsync = ref.watch(productsProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brandName ?? widget.categoryName ?? (widget.isFeaturedOnly ? 'Sản phẩm nổi bật' : 'Tất cả Sản phẩm')),
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
              final newFilter = await context.push<ProductListFilter?>(
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: productsAsync.when(
          data: (products) {
            // Khi dữ liệu từ provider thay đổi (lần đầu hoặc sau khi lọc/sắp xếp)
            // cập nhật lại danh sách sản phẩm cục bộ
            if (_filter.page == 1) {
              _products = products;
              _canLoadMore = products.length == _filter.limit;
            }
            if (_products.isEmpty) {
              return ListView(children: const [Center(child: Text('Không có sản phẩm nào phù hợp.'))]);
            }
            return _buildGridView(_products, _isLoadingMore);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi: $err')),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String text, String? currentValue) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(text),
          if (value == currentValue) const Icon(Icons.check, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Product> products, bool isLoadingMore) {
    return GridView.builder(
      controller: _scrollController,
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