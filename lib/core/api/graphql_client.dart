import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';

/// Riverpod provider để cung cấp GraphQLClient cho toàn ứng dụng.
final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  return GraphQLConfig.initializeClient(ref);
});

class GraphQLConfig {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static final HttpLink httpLink = HttpLink(
    ApiConstants.graphqlUrl,
  );

  static Future<String?> _getToken() async {
    try {
      return await _secureStorage.read(key: 'smartshop_token');
    } catch (e) {
      debugPrint("Không thể đọc token: $e");
      return null;
    }
  }

  static final AuthLink authLink = AuthLink(
    getToken: () async {
      final token = await _getToken();
      return token != null ? 'Bearer $token' : null;
    },
  );

  static final Link link = authLink.concat(httpLink);

  static GraphQLClient initializeClient(Ref ref) {
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
    return client.value;
  }

  static Future<void> setToken(String token, dynamic user) async {
    await _secureStorage.write(key: 'smartshop_token', value: token);
    await _secureStorage.write(key: 'smartshop_user', value: jsonEncode(user));
  }

  static Future<void> clearToken() async {
    await _secureStorage.deleteAll();
  }
}