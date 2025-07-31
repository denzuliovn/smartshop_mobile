import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/features/admin/data/upload_graphql.dart';

final uploadRepositoryProvider = Provider((ref) => UploadRepository(client: ref.watch(graphqlClientProvider)));

class UploadRepository {
  final GraphQLClient client;
  UploadRepository({required this.client});

  Future<void> uploadProductImages(String productId, List<XFile> files) async {
    if (files.isEmpty) return;

    List<MultipartFile> multipartFiles = [];
    for (var file in files) {
      multipartFiles.add(await MultipartFile.fromPath(
        'files', // Tên field này không quan trọng, miễn là có
        file.path,
        filename: file.name,
      ));
    }

    final options = MutationOptions(
      document: gql(UploadGraphQL.uploadProductImages),
      variables: {
        'productId': productId,
        'files': multipartFiles,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final response = result.data?['uploadProductImages'];
    if (response == null || !response['success']) {
      throw Exception(response['message'] ?? 'Upload ảnh thất bại');
    }
    // Không cần return gì cả
  }
}