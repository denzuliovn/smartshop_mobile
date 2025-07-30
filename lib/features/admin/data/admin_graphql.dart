import 'package:smartshop_mobile/features/profile/data/order_graphql.dart'; 
import 'package:smartshop_mobile/features/products/data/product_graphql.dart'; 

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

  static const String getOrder = '''
    query GetOrder(\$orderNumber: String!) {
      getOrder(orderNumber: \$orderNumber) {
        ...OrderDetails
        user {
          _id
          firstName
          lastName
          email
        }
      }
    }
    ${OrderGraphQL.orderFragment}
  ''';

  static const String updateOrderStatus = r'''
    mutation UpdateOrderStatus($orderNumber: String!, $status: OrderStatus!, $adminNotes: String) {
      updateOrderStatus(orderNumber: $orderNumber, status: $status, adminNotes: $adminNotes) {
        _id
        status
      }
    }
  ''';
  
  static const String updatePaymentStatus = r'''
    mutation UpdatePaymentStatus($orderNumber: String!, $paymentStatus: PaymentStatus!) {
      updatePaymentStatus(orderNumber: $orderNumber, paymentStatus: $paymentStatus) {
        _id
        paymentStatus
      }
    }
  ''';

  // Sử dụng lại productFragment từ file của products
  static const String getAdminProducts = '''
    query GetProducts(\$first: Int, \$offset: Int, \$orderBy: ProductsOrderBy, \$condition: ProductConditionInput) {
      products(first: \$first, offset: \$offset, orderBy: \$orderBy, condition: \$condition) {
        nodes {
          ...ProductData
        }
        totalCount
      }
    }
    ${ProductGraphQL.productFragment}
  ''';

}