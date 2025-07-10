class User {
  final String id, username, email, firstName, lastName, role, avatarUrl;
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.avatarUrl,
  });
}

class Category {
  final String id, name, imageUrl;
  Category({required this.id, required this.name, required this.imageUrl});
}

class Brand {
  final String id, name, logoUrl;
  Brand({required this.id, required this.name, required this.logoUrl});
}

class Product {
  final String id, name, description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final int stock;
  final bool isFeatured, isActive;
  final Category category;
  final Brand brand;
  final double averageRating;
  final int totalReviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.stock,
    this.isFeatured = false,
    this.isActive = true,
    required this.category,
    required this.brand,
    this.averageRating = 4.5,
    this.totalReviews = 99,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class OrderItem {
  final String id;
  final Product product;
  final int quantity;
  final double priceAtOrder; // Giá tại thời điểm đặt hàng

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.priceAtOrder,
  });
}

class Order {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final String status; // 'pending', 'processing', 'shipping', 'delivered', 'cancelled'
  final List<OrderItem> items;
  final double totalAmount;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.totalAmount,
  });
}
