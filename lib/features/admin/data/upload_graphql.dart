class UploadGraphQL {
  static const String uploadProductImages = r'''
    mutation UploadProductImages($productId: ID!, $files: [File!]!) {
      uploadProductImages(productId: $productId, files: $files) {
        success
        message
        # Không cần lấy urls vì backend không trả về
      }
    }
  ''';
}