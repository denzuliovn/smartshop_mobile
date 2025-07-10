import 'models.dart';

// ----- MOCK DATA -----

final mockUser = User(
  id: 'customer1',
  username: 'manhduc',
  email: 'customer1@gmail.com',
  firstName: 'Manh Duc',
  lastName: 'Tran',
  role: 'customer',
  avatarUrl: 'https://res.cloudinary.com/drwdwymud/image/upload/v1752117816/duc_iezqfz.jpg',
);
    
final mockAdmin = User(
  id: 'admin1',
  username: 'admin',
  email: 'admin@smartshop.com',
  firstName: 'Admin',
  lastName: 'User',
  role: 'admin',
  avatarUrl: 'https://i.pravatar.cc/150?u=admin1',
);

// --- Categories ---
final mockCategories = [
  Category(id: 'cat1', name: 'Smart Phones', imageUrl: 'https://cdn-icons-png.flaticon.com/128/244/244210.png'),
  Category(id: 'cat2', name: 'Laptop', imageUrl: 'https://cdn-icons-png.flaticon.com/512/428/428001.png'),
  Category(id: 'cat3', name: 'headphone', imageUrl: 'https://cdn-icons-png.flaticon.com/128/8407/8407995.png'),
  Category(id: 'cat4', name: 'tablet', imageUrl: 'https://cdn-icons-png.flaticon.com/128/64/64828.png'),
  Category(id: 'cat5', name: 'Smart Watch', imageUrl: 'https://cdn-icons-png.flaticon.com/128/7361/7361546.png'),
];

// --- Brands ---
final mockBrands = [
  Brand(id: 'brand1', name: 'Apple', logoUrl: 'https://cdn-icons-png.flaticon.com/512/0/747.png'),
  Brand(id: 'brand2', name: 'Samsung', logoUrl: 'https://cdn-icons-png.flaticon.com/512/5969/5969249.png'),
  Brand(id: 'brand3', name: 'Xiaomi', logoUrl: 'https://cdn-icons-png.flaticon.com/512/882/882721.png'),
  Brand(id: 'brand4', name: 'Sony', logoUrl: 'https://cdn-icons-png.flaticon.com/512/882/882718.png'),
  Brand(id: 'brand5', name: 'Dell', logoUrl: 'https://cdn-icons-png.flaticon.com/512/882/882743.png'),
];

// --- Products ---
final mockProducts = [
  Product(
    id: 'prod1',
    name: 'iPhone 15 Pro Max 256GB - Titan Tự Nhiên',
    description: 'iPhone 15 Pro. Rất Pro. Chip A17 Pro. Nút Tác vụ. Cổng kết nối USB‑C. Tất cả trong một thiết kế bằng titan chuẩn hàng không vũ trụ, bền chắc mà lại nhẹ. Đây là mẫu iPhone Pro nhẹ nhất từ trước đến nay.',
    price: 28990000,
    originalPrice: 34990000,
    images: ['https://phonesdata.com/files/models/Apple-iPhone-15-Pro-Max-581.jpg','https://phonesdata.com/files/models/Apple-iPhone-15-Pro-Max-376.jpg'],
    stock: 50,
    isFeatured: true,
    category: mockCategories[0],
    brand: mockBrands[0]
  ),
  Product(
    id: 'prod2',
    name: 'Samsung Galaxy S24 Ultra 12GB 512GB - Xanh Titan',
    description: 'Galaxy AI is here. Tìm kiếm nhanh hơn, giao tiếp thông minh hơn, sáng tạo dễ dàng hơn. Cùng với khung titan bền bỉ và camera 200MP xuất sắc.',
    price: 30490000,
    originalPrice: 37490000,
    images: ['https://phonesdata.com/files/models/Samsung-Galaxy-S24-Ultra-2.jpg', 'https://phonesdata.com/files/models/Samsung-Galaxy-S24-Ultra-3.jpg', 'https://phonesdata.com/files/models/Samsung-Galaxy-S24-Ultra-7.jpg'],
    stock: 30,
    isFeatured: true,
    category: mockCategories[0],
    brand: mockBrands[1]
  ),
  Product(
    id: 'prod3',
    name: 'MacBook Pro 14 M3 Pro 18GB/512GB - Space Black',
    description: 'MacBook Pro bứt phá với chip M3, M3 Pro và M3 Max. Công nghệ 3 nanometer và kiến trúc GPU hoàn toàn mới giúp đây trở thành những con chip tiên tiến nhất từng được chế tạo cho máy tính cá nhân.',
    price: 52490000,
    originalPrice: 55990000,
    images: ['https://res.cloudinary.com/drwdwymud/image/upload/v1752117815/prod3_wmqytg.jpg'],
    stock: 25,
    isFeatured: true,
    category: mockCategories[1],
    brand: mockBrands[0]
  ),
  Product(
    id: 'prod4',
    name: 'Tai nghe Sony WH-1000XM5 - Chống ồn đỉnh cao',
    description: 'Tai nghe chống ồn tốt nhất của chúng tôi vừa được cải tiến để mang lại cho bạn trải nghiệm nghe trọn vẹn hơn nữa. Tận hưởng chất lượng âm thanh và cuộc gọi vượt trội.',
    price: 7990000,
    images: ['https://res.cloudinary.com/drwdwymud/image/upload/v1752117816/prod4_pahclv.jpg'],
    stock: 60,
    isFeatured: false,
    category: mockCategories[4],
    brand: mockBrands[3]
  ),
];

final mockCartItems = [
  CartItem(product: mockProducts[0], quantity: 1),
  CartItem(product: mockProducts[2], quantity: 2),
];

// --- Orders ---
final mockOrders = [
  Order(
    id: 'order1',
    orderNumber: 'SS20240720001',
    orderDate: DateTime.now().subtract(const Duration(days: 3)),
    status: 'delivered',
    items: [
      OrderItem(id: 'item1', product: mockProducts[0], quantity: 1, priceAtOrder: 28990000),
    ],
    totalAmount: 28990000,
  ),
  Order(
    id: 'order2',
    orderNumber: 'SS20240718005',
    orderDate: DateTime.now().subtract(const Duration(days: 5)),
    status: 'shipping',
    items: [
      OrderItem(id: 'item2', product: mockProducts[3], quantity: 1, priceAtOrder: 7990000),
      OrderItem(id: 'item3', product: mockProducts[1], quantity: 1, priceAtOrder: 30490000),
    ],
    totalAmount: 38480000,
  ),
  Order(
    id: 'order3',
    orderNumber: 'SS20240715002',
    orderDate: DateTime.now().subtract(const Duration(days: 8)),
    status: 'cancelled',
    items: [
      OrderItem(id: 'item4', product: mockProducts[2], quantity: 1, priceAtOrder: 52490000),
    ],
    totalAmount: 52490000,
  ),
];
