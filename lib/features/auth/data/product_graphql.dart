class ProductGraphQL {
  // Fragment giúp tái sử dụng các trường dữ liệu chung cho sản phẩm
  static const String productFragment = r'''
    fragment ProductData on Product {
      _id
      name
      description
      price
      originalPrice
      images
      stock
      isFeatured
      isActive
      category {
        _id
        name
      }
      brand {
        _id
        name
      }
    }
  ''';

  // Query để lấy danh sách sản phẩm
  static const String getProducts = '''
    query GetProducts(\$first: Int, \$offset: Int) {
      products(first: \$first, offset: \$offset) {
        nodes {
          ...ProductData
        }
        totalCount
        hasNextPage
      }
    }
    $productFragment
  ''';

  // Query để lấy sản phẩm nổi bật
  static const String getFeaturedProducts = '''
    query GetFeaturedProducts {
      featuredProducts {
        ...ProductData
      }
    }
    $productFragment
  ''';
}