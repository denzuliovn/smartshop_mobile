import 'package:smartshop_mobile/core/constants/api_constants.dart';

class Address {
  final String id, fullName, phone, address, city;
  final bool isDefault;

  Address({
    required this.id, required this.fullName, required this.phone,
    required this.address, required this.city, required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      fullName: json['fullName'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}


class User {
  final String id, username, email, firstName, lastName, role, avatarUrl;
  final List<Address> addresses;

  User({
    required this.id, required this.username, required this.email,
    required this.firstName, required this.lastName, required this.role,
    required this.avatarUrl,
    this.addresses = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? rawAvatarUrl = json['avatarUrl'];
    String finalAvatarUrl;

    // Kiểm tra xem avatarUrl có phải là đường dẫn tương đối không
    if (rawAvatarUrl != null && rawAvatarUrl.startsWith('/')) {
      // Nếu đúng, thêm baseUrl vào trước
      finalAvatarUrl = "${ApiConstants.baseUrl}$rawAvatarUrl"; //
    } else {
      // Nếu đã là URL đầy đủ, hoặc là null, thì giữ nguyên
      // Nếu null thì dùng ảnh mặc định
      finalAvatarUrl = rawAvatarUrl ?? 'https://i.pravatar.cc/150';
    }

    // THÊM LOGIC XỬ LÝ ADDRESSES
    final List<dynamic> addressList = json['addresses'] ?? [];
    final List<Address> addresses = addressList.map((a) => Address.fromJson(a)).toList();


    return User(
      id: json['_id'] ?? 'N/A',
      username: json['username'] ?? 'user',
      email: json['email'] ?? 'N/A',
      firstName: json['firstName'] ?? 'Người dùng',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? 'customer',
      avatarUrl: finalAvatarUrl, // <-- Sử dụng biến đã được xử lý
      addresses: addresses,
    );
  }
}

class Category {
  final String id, name;
  final String? imageUrl;

  Category({required this.id, required this.name, this.imageUrl});
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? 'N/A',
      name: json['name'] ?? 'Chưa phân loại',
      imageUrl: json['image'], 
    );
  }
}

class Brand {
  final String id, name;
  final String? logoUrl;
  
  Brand({required this.id, required this.name, this.logoUrl});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'] ?? 'N/A',
      name: json['name'] ?? 'Không có thương hiệu',
      logoUrl: json['logo'], 
    );
  }
}

class Product {
  final String id, name, description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final int stock;
  final bool isFeatured, isActive;
  final Category? category;
  final Brand? brand;
  final double averageRating;
  final int totalReviews;

  Product({
    required this.id, required this.name, required this.description,
    required this.price, this.originalPrice, required this.images,
    required this.stock, this.isFeatured = false, this.isActive = true,
    this.category, this.brand, this.averageRating = 4.5, this.totalReviews = 99,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final List<dynamic> imageList = json['images'] ?? [];
    final List<String> images = imageList.map((e) => e.toString()).toList();

    return Product(
      id: json['_id'] ?? 'N/A',
      name: json['name'] ?? 'Sản phẩm không tên',
      description: json['description'] ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      images: images,
      stock: (json['stock'] as num? ?? 0).toInt(),
      isFeatured: json['isFeatured'] ?? false,
      isActive: json['isActive'] ?? true,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      averageRating: (json['averageRating'] as num? ?? 4.5).toDouble(),
      totalReviews: (json['totalReviews'] as num? ?? 99).toInt(),
    );
  }
}


class CartItem {
  final String id;
  final Product product;
  int quantity;
  final double unitPrice;
  final double totalPrice;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  // Hàm để tạo CartItem từ dữ liệu JSON của API
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      product: Product.fromJson(json['product']),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}

class Cart {
  final List<CartItem> items;
  final int totalItems;
  final double subtotal;

  Cart({
    required this.items,
    required this.totalItems,
    required this.subtotal,
  });

  // Trạng thái giỏ hàng rỗng
  factory Cart.empty() {
    return Cart(items: [], totalItems: 0, subtotal: 0);
  }

  // Hàm để tạo Cart từ dữ liệu JSON của API
  factory Cart.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemJsonList = json['items'] ?? [];
    return Cart(
      items: itemJsonList.map((itemJson) => CartItem.fromJson(itemJson)).toList(),
      totalItems: (json['totalItems'] as num? ?? 0).toInt(),
      subtotal: (json['subtotal'] as num? ?? 0).toDouble(),
    );
  }
}

class OrderItem {
  final String id;
  final String productName;
  final String productSku;
  final Product? product;
  final int quantity;
  final double priceAtOrder;

  OrderItem({
    required this.id, required this.productName, required this.productSku,
    this.product, required this.quantity, required this.priceAtOrder,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? 'N/A',
      productName: json['productName'] ?? 'Sản phẩm không tên', // Xử lý null
      productSku: json['productSku'] ?? 'N/A', // Xử lý null
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      priceAtOrder: (json['unitPrice'] as num? ?? 0).toDouble(),
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final String paymentStatus;
  final String status;
  final List<OrderItem> items;
  final double totalAmount;
  final User? user; 
  final dynamic customerInfo; 


  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.paymentStatus, 
    required this.items,
    required this.totalAmount,
    this.user, 
    this.customerInfo, 
  });


  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemJsonList = json['items'] ?? [];
    
    DateTime parsedDate;
    final dynamic dateValue = json['orderDate'];

    if (dateValue is num) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateValue.toInt());
    } else if (dateValue is String) {
      final intTimestamp = int.tryParse(dateValue);
      if (intTimestamp != null) {
        parsedDate = DateTime.fromMillisecondsSinceEpoch(intTimestamp);
      } else {
        try {
          parsedDate = DateTime.parse(dateValue);
        } catch (e) {
          parsedDate = DateTime.now();
        }
      }
    } else {
      parsedDate = DateTime.now();
    }

    return Order(
      id: json['_id'] ?? 'unknown_id',
      orderNumber: json['orderNumber'] ?? 'N/A',
      orderDate: parsedDate,
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending', 
      items: itemJsonList.map((item) => OrderItem.fromJson(item)).toList(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      user: json['user'] != null ? User.fromJson(json['user']) : null, 
      customerInfo: json['customerInfo'], 
    );
  }
}



class Review {
  final String id;
  final User user;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'],
      user: User.fromJson(json['user']), // Bây giờ hàm này đã tồn tại
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OrderStats {
  final int totalOrders;
  final int pendingOrders;
  final int deliveredOrders;
  final double totalRevenue;

  OrderStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.deliveredOrders,
    required this.totalRevenue,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      totalOrders: (json['totalOrders'] as num? ?? 0).toInt(),
      pendingOrders: (json['pendingOrders'] as num? ?? 0).toInt(),
      deliveredOrders: (json['deliveredOrders'] as num? ?? 0).toInt(),
      totalRevenue: (json['totalRevenue'] as num? ?? 0).toDouble(),
    );
  }
}
