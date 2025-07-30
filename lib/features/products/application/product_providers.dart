import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/data/product_repository.dart';

// --- LỚP QUẢN LÝ CÁC THAM SỐ LỌC VÀ SẮP XẾP ---
@immutable
class ProductListFilter {
  final int page;
  final int limit;
  final String orderBy;
  final Map<String, dynamic> condition;

  const ProductListFilter({
    this.page = 1,
    this.limit = 20, // Số sản phẩm mỗi trang
    this.orderBy = 'CREATED_DESC',
    this.condition = const {},
  });

  ProductListFilter copyWith({
    int? page,
    String? orderBy,
    Map<String, dynamic>? condition,
  }) {
    return ProductListFilter(
      page: page ?? this.page,
      limit: this.limit,
      orderBy: orderBy ?? this.orderBy,
      condition: condition ?? this.condition,
    );
  }
}

// --- LỚP QUẢN LÝ TRẠNG THÁI CỦA DANH SÁCH SẢN PHẨM ---
@immutable
class PaginatedProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool canLoadMore;
  final String? error;

  const PaginatedProductsState({
    this.products = const [],
    this.isLoading = true,
    this.canLoadMore = true,
    this.error,
  });

  PaginatedProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? canLoadMore,
    String? error,
  }) {
    return PaginatedProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      error: error,
    );
  }
}

// --- STATE NOTIFIER ĐỂ XỬ LÝ TOÀN BỘ LOGIC ---
class PaginatedProductsNotifier extends StateNotifier<PaginatedProductsState> {
  final Ref _ref;
  ProductListFilter _currentFilter;

  PaginatedProductsNotifier(this._ref, {required ProductListFilter initialFilter})
      : _currentFilter = initialFilter,
        super(const PaginatedProductsState()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    _currentFilter = _currentFilter.copyWith(page: 1);
    state = const PaginatedProductsState(isLoading: true, products: []);
    
    try {
      final newProducts = await _fetchProducts(_currentFilter);
      state = PaginatedProductsState(
        products: newProducts,
        isLoading: false,
        canLoadMore: newProducts.length == _currentFilter.limit,
      );
    } catch (e) {
      state = PaginatedProductsState(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.canLoadMore) return;

    state = state.copyWith(isLoading: true);
    _currentFilter = _currentFilter.copyWith(page: _currentFilter.page + 1);

    try {
      final newProducts = await _fetchProducts(_currentFilter);
      state = state.copyWith(
        products: [...state.products, ...newProducts],
        isLoading: false,
        canLoadMore: newProducts.length == _currentFilter.limit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
  
  void updateFilter(ProductListFilter newFilter) {
    _currentFilter = newFilter;
    loadFirstPage();
  }

  Future<List<Product>> _fetchProducts(ProductListFilter filter) {
    return _ref.read(productRepositoryProvider).getProducts(
          limit: filter.limit,
          offset: (filter.page - 1) * filter.limit,
          orderBy: filter.orderBy,
          condition: filter.condition,
        );
  }
}

// --- PROVIDER CHÍNH CHO DANH SÁCH SẢN PHẨM PHÂN TRANG ---
final paginatedProductsProvider = StateNotifierProvider.autoDispose
    .family<PaginatedProductsNotifier, PaginatedProductsState, ProductListFilter>(
  (ref, initialFilter) {
    return PaginatedProductsNotifier(ref, initialFilter: initialFilter);
  },
);

final productsProvider = FutureProvider.autoDispose.family<List<Product>, ProductListFilter>((ref, filter) {
  final offset = (filter.page - 1) * filter.limit;
  return ref.watch(productRepositoryProvider).getProducts(
    limit: filter.limit, 
    offset: offset,
    orderBy: filter.orderBy,
    condition: filter.condition.isEmpty ? null : filter.condition, // Gửi null nếu condition rỗng
  );
});


// --- CÁC PROVIDER KHÁC ---

// Provider để lấy chi tiết một sản phẩm
final productDetailProvider = FutureProvider.autoDispose.family<Product, String>((ref, productId) {
  return ref.watch(productRepositoryProvider).getProductById(productId);
});

// Provider để lấy danh sách sản phẩm nổi bật
final featuredProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getFeaturedProducts();
});

// Provider để lấy 4 sản phẩm mới nhất cho section "Dành cho bạn"
final latestProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts(
    limit: 4, 
    offset: 0, 
    orderBy: 'CREATED_DESC'
  );
});

// Provider để lấy danh sách danh mục
final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) {
  return ref.watch(productRepositoryProvider).getAllCategories();
});

// Provider để lấy danh sách thương hiệu
final brandsProvider = FutureProvider.autoDispose<List<Brand>>((ref) {
  return ref.watch(productRepositoryProvider).getAllBrands();
});


