class AdminGraphQL {
  // Query để lấy các số liệu thống kê đơn hàng
  static const String getOrderStats = r'''
    query GetOrderStats {
      getOrderStats {
        totalOrders
        pendingOrders
        confirmedOrders
        shippingOrders
        deliveredOrders
        cancelledOrders
        totalRevenue
        todayOrders
      }
    }
  ''';

  static const String getAllOrders = r'''
    query GetAllOrders($first: Int, $offset: Int, $orderBy: OrdersOrderBy, $condition: OrderConditionInput, $search: String) {
      getAllOrders(first: $first, offset: $offset, orderBy: $orderBy, condition: $condition, search: $search) {
        nodes {
          _id
          orderNumber
          orderDate
          status
          paymentStatus
          totalAmount
          customerInfo {
            fullName
          }
          user {
            email
          }
          items {
            _id
          }
        }
        totalCount
      }
    }
  ''';

}