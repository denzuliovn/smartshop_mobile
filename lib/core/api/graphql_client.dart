import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';

// Riverpod provider để cung cấp GraphQLClient cho toàn ứng dụng.
final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  return GraphQLConfig.initializeClient();
});

class GraphQLConfig {
  // Dùng để lưu trữ token và thông tin user an toàn
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Tạo một link HTTP đến địa chỉ GraphQL server
  static final HttpLink httpLink = HttpLink(
    ApiConstants.graphqlUrl,
  );

  /// Hàm private này sẽ được gọi trước mỗi request để lấy token
  static Future<String?> _getToken() async {
    try {
      return await _secureStorage.read(key: 'smartshop_token');
    } catch (e) {
      debugPrint("Không thể đọc token: $e");
      return null;
    }
  }

  /// Middleware sẽ đính kèm token vào header của mỗi request
  static final AuthLink authLink = AuthLink(
    getToken: () async {
      final token = await _getToken();
      return token != null ? 'Bearer $token' : null;
    },
  );

  /// Nối chuỗi các link lại với nhau.
  static final Link link = authLink.concat(httpLink);

  /// Hàm chính để khởi tạo client
  static GraphQLClient initializeClient() {
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
    return client.value;
  }

  // Hàm tiện ích để lưu token và user sau khi đăng nhập thành công
  static Future<void> setToken(String token, dynamic user) async {
    await _secureStorage.write(key: 'smartshop_token', value: token);
    await _secureStorage.write(key: 'smartshop_user', value: jsonEncode(user));
  }
  
  // Hàm mới chỉ để cập nhật thông tin user trong storage (để không ghi đè token khi update profile)
  static Future<void> updateStoredUser(dynamic user) async {
    await _secureStorage.write(key: 'smartshop_user', value: jsonEncode(user)); //
  }

  // Hàm tiện ích để lấy thông tin user đã lưu
  static Future<Map<String, dynamic>?> getStoredUser() async {
    try {
      final userJson = await _secureStorage.read(key: 'smartshop_user');
      if (userJson != null) {
        return jsonDecode(userJson);
      }
      return null;
    } catch (e) {
      debugPrint("Không thể đọc thông tin user đã lưu: $e");
      return null;
    }
  }

  // Hàm tiện ích để xóa token và user khi logout
  static Future<void> clearToken() async {
    await _secureStorage.deleteAll();
  }
}