// FILE PATH: lib/features/profile/data/profile_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/profile/data/profile_graphql.dart';
import 'package:smartshop_mobile/features/profile/data/address_graphql.dart';

// Provider cho repository (không thay đổi)
final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(client: ref.watch(graphqlClientProvider));
});

class ProfileRepository {
  final GraphQLClient client;
  ProfileRepository({required this.client});

  // Address
  Future<User> addAddress(Map<String, dynamic> addressData) async {
    final options = MutationOptions(
      document: gql(AddressGraphQL.addAddress),
      variables: {'input': addressData},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    return User.fromJson(result.data!['addAddress']);
  }

  Future<User> updateAddress(String addressId, Map<String, dynamic> addressData) async {
    final options = MutationOptions(
      document: gql(AddressGraphQL.updateAddress),
      variables: {'addressId': addressId, 'input': addressData},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    return User.fromJson(result.data!['updateAddress']);
  }

  Future<User> deleteAddress(String addressId) async {
    final options = MutationOptions(
      document: gql(AddressGraphQL.deleteAddress),
      variables: {'addressId': addressId},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    return User.fromJson(result.data!['deleteAddress']);
  }

  Future<User> setDefaultAddress(String addressId) async {
    final options = MutationOptions(
      document: gql(AddressGraphQL.setDefaultAddress),
      variables: {'addressId': addressId},
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    return User.fromJson(result.data!['setDefaultAddress']);
  }


  // ===== THAY THẾ NỘI DUNG CỦA HÀM NÀY =====
  Future<User> updateProfile({
    required String userId, // userId không còn cần thiết cho API thật vì server đọc từ token
    required String firstName,
    required String lastName
  }) async {

    // 1. Định nghĩa mutation options
    final options = MutationOptions(
      document: gql(ProfileGraphQL.updateProfile), // [cite: 544]
      variables: {
        'input': {
          'firstName': firstName,
          'lastName': lastName,
        }
      },
      // Thêm fetchPolicy để đảm bảo dữ liệu luôn được làm mới
      fetchPolicy: FetchPolicy.networkOnly,
    );

    // 2. Gửi mutation đến server
    final result = await client.mutate(options);

    // 3. Xử lý lỗi nếu có
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    // 4. Lấy dữ liệu trả về và chuyển đổi thành đối tượng User
    final data = result.data?['updateProfile'];
    
    if (data == null) {
      throw Exception('Cập nhật thất bại, không nhận được dữ liệu trả về.');
    }

    final user = User.fromJson(data);
    print('[REPO] updateProfile tạo User object với avatarUrl: ${user.avatarUrl}');

    return user;
  }

  Future<User> updateAvatar(XFile imageFile) async {
    // 1. Chuyển XFile sang MultipartFile để gửi đi
    final bytes = await imageFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'file', // Tên field này phải khớp với server
      bytes,
      filename: imageFile.name,
      contentType: MediaType('image', imageFile.name.split('.').last),
    );

    // 2. Định nghĩa mutation options
    final options = MutationOptions(
      document: gql(ProfileGraphQL.updateAvatar),
      variables: {
        'file': multipartFile,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    // 3. Gửi mutation
    final result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['updateAvatar'];
    if (data == null) {
      throw Exception('Cập nhật avatar thất bại.');
    }

    final user = User.fromJson(data);
    print('[REPO] updateAvatar tạo User object với avatarUrl: ${user.avatarUrl}');

    return user;
  }
}