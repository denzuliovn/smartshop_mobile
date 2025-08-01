import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/data/product_graphql.dart';
import 'review_graphql.dart';
import 'package:smartshop_mobile/core/mock_data/mock_data.dart';
import 'dart:convert';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(client: ref.watch(graphqlClientProvider));
});

class ProductRepository {
  final GraphQLClient client;
  ProductRepository({required this.client});

  // --- HÀM ĐƯỢC CẬP NHẬT LOGIC ---
  Future<List<Product>> getFeaturedProducts() async {
    // 1. Thử lấy sản phẩm nổi bật trước
    final featuredOptions = QueryOptions(
      document: gql(ProductGraphQL.getFeaturedProducts),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final featuredResult = await client.query(featuredOptions);
    if (featuredResult.hasException) {
      // Nếu có lỗi, vẫn thử bước tiếp theo thay vì báo lỗi ngay
      print(
          "Lỗi khi lấy featuredProducts: ${featuredResult.exception.toString()}");
    }

    final List<dynamic> featuredList =
        featuredResult.data?['featuredProducts'] ?? [];

    // 2. Nếu có sản phẩm nổi bật, trả về ngay
    if (featuredList.isNotEmpty) {
      print("✅ Đã tìm thấy ${featuredList.length} sản phẩm nổi bật.");
      return featuredList.map((json) => Product.fromJson(json)).toList();
    }

    // 3. Nếu không có sản phẩm nổi bật, lấy 8 sản phẩm mới nhất để thay thế
    print("ℹ️ Không có sản phẩm nổi bật, đang lấy sản phẩm mới nhất...");
    final latestOptions = QueryOptions(
      document: gql(ProductGraphQL.getProducts),
      variables: {'first': 8, 'offset': 0}, // Lấy 8 sản phẩm đầu
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final latestResult = await client.query(latestOptions);
    if (latestResult.hasException) {
      throw Exception(latestResult.exception.toString());
    }

    final List<dynamic> latestList =
        latestResult.data?['products']?['nodes'] ?? [];
    print("✅ Đã lấy được ${latestList.length} sản phẩm mới nhất để thay thế.");
    return latestList.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> getProductById(String id) async {
    final options = QueryOptions(
      document: gql(ProductGraphQL.getProductById),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    );
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());
    final Map<String, dynamic>? productJson = result.data?['product'];
    if (productJson == null) throw Exception('Không tìm thấy sản phẩm');
    return Product.fromJson(productJson);
  }

  // --- HÀM MỚI 1 ---
  Future<List<Category>> getAllCategories() async {
    final options = QueryOptions(
      document: gql(ProductGraphQL.getAllCategories),
      fetchPolicy:
          FetchPolicy.networkOnly, // Ưu tiên cache vì danh mục ít thay đổi
    );
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());

    final List<dynamic> list = result.data?['allCategories'] ?? [];
    return list.map((json) => Category.fromJson(json)).toList();
  }

  // --- HÀM MỚI 2 ---
  Future<List<Brand>> getAllBrands() async {
    final options = QueryOptions(
      document: gql(ProductGraphQL.getAllBrands),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());

    final List<dynamic> list = result.data?['allBrands'] ?? [];
    return list.map((json) => Brand.fromJson(json)).toList();
  }

  Future<List<Product>> searchProducts(String query, {int? limit}) async {
    final options = QueryOptions(
      document: gql(ProductGraphQL.searchProducts),
      variables: {
        'query': query,
        'first': limit,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic> list = result.data?['searchProducts']?['nodes'] ?? [];
    return list.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> getProducts({
    required int limit,
    required int offset,
    String? orderBy,
    Map<String, dynamic>? condition,
  }) async {
    final variables = {
      'first': limit,
      'offset': offset,
      'orderBy': orderBy,
      // Chỉ thêm condition vào variables nếu nó không null và không rỗng
      if (condition != null && condition.isNotEmpty) 'condition': condition,
    };

    // --- THÊM LOG Ở ĐÂY ---
    print("🚀 [ProductRepository] Calling API 'getProducts' with variables:");
    print(jsonEncode(variables)); // In ra chuỗi JSON để xem chi tiết

    final options = QueryOptions(
      document: gql(ProductGraphQL.getProducts),
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await client.query(options);

    if (result.hasException) {
      // In lỗi ra console để gỡ lỗi
      print("❌ [ProductRepository] API Error: ${result.exception.toString()}");
      throw Exception(result.exception.toString());
    }

    final List<dynamic> productList = result.data?['products']?['nodes'] ?? [];
    print("✅ [ProductRepository] Received ${productList.length} products.");
    return productList.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Review>> getProductReviews(String productId) async {
    final options = QueryOptions(
      document: gql(ReviewGraphQL.getProductReviews),
      variables: {'productId': productId},
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());
    final List<dynamic> list = result.data?['getProductReviews'] ?? [];
    return list.map((json) => Review.fromJson(json)).toList();
  }

  Future<void> createReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final options = MutationOptions(
      document: gql(ReviewGraphQL.createReview),
      variables: {
        'input': {
          'productId': productId,
          'rating': rating,
          'comment': comment,
        }
      },
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }
}
