import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/admin/data/admin_graphql.dart';
import 'package:smartshop_mobile/features/products/data/product_graphql.dart';
import 'dart:io';
import 'package:http/http.dart' show MultipartFile;
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

final adminRepositoryProvider = Provider((ref) => AdminRepository(client: ref.watch(graphqlClientProvider)));

class AdminRepository {
  final GraphQLClient client;
  AdminRepository({required this.client});

  Future<Category> createCategory(String name) async {
    const String mutation = r'''
      mutation CreateCategory($input: CategoryInput!) {
        createCategory(input: $input) {
          _id
          name
        }
      }
    ''';
    final options = MutationOptions(
      document: gql(mutation),
      variables: {'input': {'name': name}},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    return Category.fromJson(result.data!['createCategory']);
  }

  Future<Brand> createBrand(String name) async {
    const String mutation = r'''
      mutation CreateBrand($input: BrandInput!) {
        createBrand(input: $input) {
          _id
          name
        }
      }
    ''';
    final options = MutationOptions(
      document: gql(mutation),
      variables: {'input': {'name': name}},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    return Brand.fromJson(result.data!['createBrand']);
  }

  Future<void> bulkUpdateProducts({required List<String> ids, double? price, int? stock}) async {
    final String mutation = r'''
      mutation BulkUpdate($input: BulkUpdateInput!) {
        bulkUpdateProducts(input: $input)
      }
    ''';
    final Map<String, dynamic> input = {'ids': ids};
    if (price != null) input['price'] = price;
    if (stock != null) input['stock'] = stock;

    final options = MutationOptions(document: gql(mutation), variables: {'input': input});
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }

  Future<Map<String, dynamic>> importProducts(File file) async {
    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: file.path.split('/').last,
      contentType: MediaType('text', 'csv'),
    );
    final options = MutationOptions(
      document: gql(r'''
        mutation ImportProducts($file: File!) {
          importProducts(file: $file) {
            success message created updated errors
          }
        }
      '''),
      variables: {'file': multipartFile},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    return result.data?['importProducts'] as Map<String, dynamic>;
  }

  Future<List<Product>> getAllProductsSimple() async {
    final options = QueryOptions(
      // XÓA CHỮ 'r' Ở ĐẦU DÒNG DƯỚI
      document: gql(''' 
        query AllProductsSimple {
          allProducts { ...ProductData }
        }
        ${ProductGraphQL.productFragment}
      '''),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());
    final List<dynamic> list = result.data?['allProducts'] ?? [];
    return list.map((json) => Product.fromJson(json)).toList();
  }

  Future<void> deleteManyProducts(List<String> ids) async {
    // Cần định nghĩa mutation string này trong admin_graphql.dart
    final String deleteManyMutation = r'''
      mutation DeleteManyProducts($ids: [ID!]!) {
        deleteManyProducts(ids: $ids)
      }
    ''';
    final options = MutationOptions(
      document: gql(deleteManyMutation),
      variables: {'ids': ids},
    );
    final result = await client.mutate(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<OrderStats> getOrderStats() async {
    final options = QueryOptions(
      document: gql(AdminGraphQL.getOrderStats),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final statsJson = result.data?['getOrderStats'];
    if (statsJson == null) {
      throw Exception('Không thể lấy dữ liệu thống kê');
    }

    return OrderStats.fromJson(statsJson);
  }

  Future<List<Order>> getAllOrders({int limit = 10, int offset = 0, String? search}) async {
    final options = QueryOptions(
      document: gql(AdminGraphQL.getAllOrders),
      variables: {
        'first': limit,
        'offset': offset,
        'search': search,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());
    
    final List<dynamic> list = result.data?['getAllOrders']?['nodes'] ?? [];
    return list.map((json) => Order.fromJson(json)).toList();
  }

  Future<Order> getOrder(String orderNumber) async {
    final options = QueryOptions(
      document: gql(AdminGraphQL.getOrder),
      variables: {'orderNumber': orderNumber},
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());
    
    final orderJson = result.data?['getOrder'];
    if (orderJson == null) throw Exception('Không tìm thấy đơn hàng');
    
    return Order.fromJson(orderJson);
  }

  Future<void> updateOrderStatus({required String orderNumber, required String status}) async {
    final options = MutationOptions(
      document: gql(AdminGraphQL.updateOrderStatus),
      variables: {'orderNumber': orderNumber, 'status': status},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }


  Future<void> updatePaymentStatus({required String orderNumber, required String paymentStatus}) async {
    final options = MutationOptions(
      document: gql(AdminGraphQL.updatePaymentStatus),
      variables: {'orderNumber': orderNumber, 'paymentStatus': paymentStatus},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }

  Future<List<Product>> getProducts() async {
    final options = QueryOptions(
      document: gql(AdminGraphQL.getAdminProducts),
      // Tạm thời chưa có phân trang/lọc để đơn giản hóa
      variables: {'first': 50, 'offset': 0},
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());
    
    final List<dynamic> list = result.data?['products']?['nodes'] ?? [];
    return list.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    final options = MutationOptions(
      document: gql(AdminGraphQL.createProduct),
      variables: {'input': productData},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    
    return Product.fromJson(result.data!['createProduct']);
  }
  
  Future<Product> updateProduct(String id, Map<String, dynamic> productData) async {
    final options = MutationOptions(
      document: gql(AdminGraphQL.updateProduct),
      variables: {'id': id, 'input': productData},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());

    return Product.fromJson(result.data!['updateProduct']);
  }

  Future<void> deleteProduct(String id) async {
    final options = MutationOptions(
      document: gql(AdminGraphQL.deleteProduct),
      variables: {'id': id},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }

}