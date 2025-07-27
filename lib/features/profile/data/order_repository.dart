import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/profile/data/order_graphql.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository(client: ref.watch(graphqlClientProvider)));

class OrderRepository {
  final GraphQLClient client;
  OrderRepository({required this.client});

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> customerInfo, String paymentMethod) async {
    final options = MutationOptions(
      document: gql(OrderGraphQL.createOrderFromCart),
      variables: {
        'input': {
          'customerInfo': customerInfo,
          'paymentMethod': paymentMethod,
        }
      },
    );

    final result = await client.mutate(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final response = result.data?['createOrderFromCart'];
    if (response == null) {
      throw Exception('Tạo đơn hàng thất bại');
    }
    return response;
  }
  Future<List<Order>> getMyOrders() async {
    final options = QueryOptions(
      document: gql(OrderGraphQL.getMyOrders),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic> orderList = result.data?['getMyOrders']?['nodes'] ?? [];
    return orderList.map((json) => Order.fromJson(json)).toList();
  }

  Future<Order> getOrderDetails(String orderNumber) async {
    final options = QueryOptions(
      document: gql(OrderGraphQL.getMyOrder),
      variables: {'orderNumber': orderNumber},
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    
    final orderJson = result.data?['getMyOrder'];
    if (orderJson == null) {
      throw Exception('Không tìm thấy đơn hàng');
    }

    return Order.fromJson(orderJson);
  }
}