class WishlistGraphQL {
  static const String productFragmentForWishlist = r'''
    fragment ProductDataForWishlist on Product {
      _id
      name
      price
      originalPrice
      images
      stock
      category { _id name }
      brand { _id name }
    }
  ''';
  
  static const String wishlistItemFragment = r'''
    fragment WishlistItemData on WishlistItem {
      _id
      product {
        ...ProductDataForWishlist
      }
    }
  ''';

  // --- SỬA LẠI CÁC CÂU LỆNH SỬ DỤNG FRAGMENT ---

  // Kết hợp query và các fragment cần thiết
  static const String getMyWishlist = '''
    query GetMyWishlist {
      myWishlist {
        ...WishlistItemData
      }
    }
    $wishlistItemFragment
    $productFragmentForWishlist
  ''';
  
  static const String isProductInWishlist = r'''
    query IsProductInWishlist($productId: ID!) {
      isProductInWishlist(productId: $productId)
    }
  ''';

  // Kết hợp mutation và các fragment cần thiết
  static const String addToWishlist = '''
    mutation AddToWishlist(\$productId: ID!) {
      addToWishlist(productId: \$productId) {
        ...WishlistItemData
      }
    }
    $wishlistItemFragment
    $productFragmentForWishlist
  ''';
  
  static const String removeFromWishlist = r'''
    mutation RemoveFromWishlist($productId: ID!) {
      removeFromWishlist(productId: $productId)
    }
  ''';
}