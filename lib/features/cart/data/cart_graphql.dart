class CartGraphQL {
  static const String cartItemFragment = r'''
    fragment CartItemData on CartItem {
      _id
      quantity
      unitPrice
      totalPrice
      product {
        _id
        name
        price
        originalPrice
        images
        stock
        isActive
        category { name }
        brand { name }
      }
    }
  ''';

  static const String getCart = '''
    query GetCart {
      getCart {
        items {
          ...CartItemData
        }
        totalItems
        subtotal
      }
    }
    $cartItemFragment
  ''';

  static const String getCartItemCount = r'''
    query GetCartItemCount {
      getCartItemCount
    }
  ''';

  static const String addToCart = '''
    mutation AddToCart(\$input: AddToCartInput!) {
      addToCart(input: \$input) {
        ...CartItemData
      }
    }
    $cartItemFragment
  ''';
  
  static const String updateCartItem = '''
    mutation UpdateCartItem(\$input: UpdateCartInput!) {
      updateCartItem(input: \$input) {
        ...CartItemData
      }
    }
    $cartItemFragment
  ''';
  
  static const String removeFromCart = r'''
    mutation RemoveFromCart($productId: ID!) {
      removeFromCart(productId: $productId)
    }
  ''';
}