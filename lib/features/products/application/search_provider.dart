import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/data/product_repository.dart';

// 1. Định nghĩa các trạng thái của việc tìm kiếm
abstract class SearchState {}
class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}

// CẬP NHẬT: Thêm 'query' vào SearchLoaded
class SearchLoaded extends SearchState {
  final List<Product> products;
  final String query;
  SearchLoaded(this.products, this.query);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

// 2. Tạo StateNotifier
class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  Timer? _debounce;

  SearchNotifier(this._ref) : super(SearchInitial());

  void search(String query) {
    // Dùng debounce để tránh gọi API liên tục khi người dùng đang gõ
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().length < 2) {
        state = SearchInitial(); // Không tìm nếu query quá ngắn
        return;
      }
      
      state = SearchLoading();
      try {
        final products = await _ref.read(productRepositoryProvider).searchProducts(query.trim(), limit: 20);
        // CẬP NHẬT: Lưu lại query vào state
        state = SearchLoaded(products, query.trim());
      } catch (e) {
        state = SearchError(e.toString());
      }
    });
  }

  void clear() {
    state = SearchInitial();
  }
}

// 3. Tạo Provider (CẬP NHẬT: Xóa .autoDispose)
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});