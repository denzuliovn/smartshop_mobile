class ProductGraphQL {
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
      category { _id name }
      brand { _id name }
    }
  ''';

  static const String getProducts = '''
    query GetProducts(\$first: Int, \$offset: Int) {
      products(first: \$first, offset: \$offset) {
        nodes { ...ProductData }
        totalCount
        hasNextPage
      }
    }
    $productFragment
  ''';

  static const String getFeaturedProducts = '''
    query GetFeaturedProducts {
      featuredProducts { ...ProductData }
    }
    $productFragment
  ''';

  // --- QUERY MỚI ---
  static const String getProductById = '''
    query GetProduct(\$id: ID!) {
      product(id: \$id) {
        ...ProductData
      }
    }
    $productFragment
  ''';

  static const String getAllCategories = r'''
    query GetAllCategories {
      allCategories {
        _id
        name
        image
      }
    }
  ''';

  static const String getAllBrands = r'''
    query GetAllBrands {
      allBrands {
        _id
        name
        logo
      }
    }
  ''';
}