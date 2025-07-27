import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/cart/data/cart_graphql.dart';

final cartRepositoryProvider = Provider((ref) => CartRepository(client: ref.watch(graphqlClientProvider)));

class CartRepository {
  final GraphQLClient client;
  CartRepository({required this.client});

  Future<Cart> getCart() async {
    final options = QueryOptions(document: gql(CartGraphQL.getCart), fetchPolicy: FetchPolicy.networkOnly);
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());
    
    final cartJson = result.data?['getCart'];
    return cartJson != null ? Cart.fromJson(cartJson) : Cart.empty();
  }

  Future<void> addToCart(String productId, int quantity) async {
    final options = MutationOptions(
      document: gql(CartGraphQL.addToCart),
      variables: {'input': {'productId': productId, 'quantity': quantity}},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }

  Future<void> updateCartItem(String productId, int quantity) async {
    final options = MutationOptions(
      document: gql(CartGraphQL.updateCartItem),
      variables: {'input': {'productId': productId, 'quantity': quantity}},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }
  
  Future<void> removeFromCart(String productId) async {
    final options = MutationOptions(
      document: gql(CartGraphQL.removeFromCart),
      variables: {'productId': productId},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }
}