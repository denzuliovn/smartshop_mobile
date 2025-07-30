import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/features/auth/data/auth_graphql.dart';

// Provider cho repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return AuthRepository(client: client);
});

class AuthRepository {
  final GraphQLClient client;
  AuthRepository({required this.client});

  Future<Map<String, dynamic>> login(String username, String password) async {
    final options = MutationOptions(
      document: gql(AuthGraphQL.loginMutation),
      variables: {
        'input': {'username': username, 'password': password}
      },
    );
    final result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    
    final response = result.data?['login'];
    if (response == null || !response['success']) {
      throw Exception(response['message'] ?? 'Đăng nhập thất bại');
    }
    
    return response['data'];
  }
  
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final options = MutationOptions(
      document: gql(AuthGraphQL.registerMutation),
      variables: {
        'input': {
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName
        }
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final response = result.data?['register'];
    if (response == null || !response['success']) {
      throw Exception(response['message'] ?? 'Đăng ký thất bại');
    }
  }

  Future<void> sendOTP(String email) async {
    final options = MutationOptions(
      document: gql(AuthGraphQL.sendPasswordResetOTP),
      variables: {'input': {'email': email}},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    
    final response = result.data?['sendPasswordResetOTP'];
    if (response == null || !response['success']) {
      throw Exception(response['message'] ?? 'Gửi OTP thất bại');
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    final options = MutationOptions(
      document: gql(AuthGraphQL.verifyOTPAndResetPassword),
      variables: {'input': {'email': email, 'otp': otp, 'newPassword': newPassword}},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());

    final response = result.data?['verifyOTPAndResetPassword'];
    if (response == null || !response['success']) {
      throw Exception(response['message'] ?? 'Đặt lại mật khẩu thất bại');
    }
  }

}