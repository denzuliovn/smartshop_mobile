import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/data/product_repository.dart';

// Provider để lấy danh sách sản phẩm nổi bật
final featuredProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  // Theo dõi repository và gọi hàm để lấy dữ liệu
  return ref.watch(productRepositoryProvider).getFeaturedProducts();
});


// Dùng `.family` để có thể truyền tham số (productId) vào provider
final productDetailProvider = FutureProvider.autoDispose.family<Product, String>((ref, productId) {
  // Gọi hàm trong repository với productId nhận được
  return ref.watch(productRepositoryProvider).getProductById(productId);
});


final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) {
  return ref.watch(productRepositoryProvider).getAllCategories();
});


final brandsProvider = FutureProvider.autoDispose<List<Brand>>((ref) {
  return ref.watch(productRepositoryProvider).getAllBrands();
});
