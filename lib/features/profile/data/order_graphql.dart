class OrderGraphQL {
  // Fragment cho thông tin cơ bản của một đơn hàng
  static const String orderFragment = r'''
    fragment OrderDetails on Order {
      _id
      orderNumber
      status
      paymentMethod
      paymentStatus
      totalAmount
      orderDate
      customerInfo {
        fullName
        phone
        address
        city
      }
      items {
        _id
        productName
        productSku
        quantity
        unitPrice
        totalPrice
        product {
          _id
          images
        }
        productSnapshot {
          images
        }
      }
    }
  ''';

  // Mutation để tạo đơn hàng từ giỏ hàng
  static const String createOrderFromCart = '''
    mutation CreateOrderFromCart(\$input: CreateOrderInput!) {
      createOrderFromCart(input: \$input) {
        orderNumber
        _id
      }
    }
  ''';

  // Query để lấy tất cả đơn hàng của người dùng hiện tại
  static const String getMyOrders = '''
    query GetMyOrders(\$first: Int, \$offset: Int) {
      getMyOrders(first: \$first, offset: \$offset) {
        nodes {
          ...OrderDetails
        }
        totalCount
      }
    }
    $orderFragment
  ''';

  // Query để lấy chi tiết một đơn hàng
  static const String getMyOrder = '''
    query GetMyOrder(\$orderNumber: String!) {
      getMyOrder(orderNumber: \$orderNumber) {
        ...OrderDetails
      }
    }
    $orderFragment
  ''';
}