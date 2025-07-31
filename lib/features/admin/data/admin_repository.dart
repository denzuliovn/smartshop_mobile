import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/admin/data/admin_graphql.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository(client: ref.watch(graphqlClientProvider)));

class AdminRepository {
  final GraphQLClient client;
  AdminRepository({required this.client});

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