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
  final String id, name;
  final String? imageUrl;

  Category({required this.id, required this.name, this.imageUrl});
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'No Category',
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
      id: json['_id'] ?? '',
      name: json['name'] ?? 'No Brand',
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
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.stock,
    this.isFeatured = false,
    this.isActive = true,
    this.category,
    this.brand,
    this.averageRating = 4.5,
    this.totalReviews = 99,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final List<dynamic> imageList = json['images'] ?? [];
    final List<String> images = imageList.map((e) => e.toString()).toList();

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'No Name',
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
    required this.id,
    required this.productName,
    required this.productSku,
    this.product,
    required this.quantity,
    required this.priceAtOrder,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'],
      productName: json['productName'],
      productSku: json['productSku'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      quantity: (json['quantity'] as num).toInt(),
      priceAtOrder: (json['unitPrice'] as num).toDouble(),
    );
  }
}


class Order {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final String status;
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

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemJsonList = json['items'] ?? [];
    
    // --- LOGIC XỬ LÝ DATE MẠNH MẼ HƠN ---
    DateTime parsedDate;
    final dynamic dateValue = json['orderDate'];

    if (dateValue is num) {
      // Trường hợp 1: Backend trả về số (timestamp)
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateValue.toInt());
    } else if (dateValue is String) {
      // Trường hợp 2: Backend trả về chuỗi
      // Thử parse nó như một con số trước
      final intTimestamp = int.tryParse(dateValue);
      if (intTimestamp != null) {
        // Nếu parse thành công -> đây là chuỗi timestamp
        parsedDate = DateTime.fromMillisecondsSinceEpoch(intTimestamp);
      } else {
        // Nếu không, thử parse như một chuỗi date ISO
        try {
          parsedDate = DateTime.parse(dateValue);
        } catch (e) {
          // Nếu tất cả đều thất bại, dùng ngày hiện tại
          parsedDate = DateTime.now();
        }
      }
    } else {
      // Trường hợp 3: Kiểu dữ liệu không xác định hoặc null
      parsedDate = DateTime.now();
    }
    // --- KẾT THÚC LOGIC XỬ LÝ DATE ---

    return Order(
      id: json['_id'] ?? 'N/A',
      orderNumber: json['orderNumber'] ?? 'N/A',
      orderDate: parsedDate,
      status: json['status'] ?? 'pending',
      items: itemJsonList.map((item) => OrderItem.fromJson(item)).toList(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
    );
  }
}
