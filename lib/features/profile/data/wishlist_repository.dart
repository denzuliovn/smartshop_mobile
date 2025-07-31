import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/profile/data/wishlist_graphql.dart';

final wishlistRepositoryProvider = Provider((ref) => WishlistRepository(client: ref.watch(graphqlClientProvider)));

class WishlistRepository {
  final GraphQLClient client;
  WishlistRepository({required this.client});

  Future<List<Product>> getMyWishlist() async {
    final options = QueryOptions(document: gql(WishlistGraphQL.getMyWishlist), fetchPolicy: FetchPolicy.networkOnly);
    final result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());
    
    final List<dynamic> items = result.data?['myWishlist'] ?? [];
    return items.map((item) => Product.fromJson(item['product'])).toList();
  }
  
  Future<void> addToWishlist(String productId) async {
    final options = MutationOptions(document: gql(WishlistGraphQL.addToWishlist), variables: {'productId': productId});
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }

  Future<void> removeFromWishlist(String productId) async {
    final options = MutationOptions(document: gql(WishlistGraphQL.removeFromWishlist), variables: {'productId': productId});
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }
  
  Future<bool> isProductInWishlist(String productId) async {
    final options = QueryOptions(document: gql(WishlistGraphQL.isProductInWishlist), variables: {'productId': productId});
    final result = await client.query(options);
    if (result.hasException) return false;
    return result.data?['isProductInWishlist'] ?? false;
  }
}