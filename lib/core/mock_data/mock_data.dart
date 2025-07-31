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

final mockReviews = [
  Review(
    id: 'review1',
    user: mockUser,
    rating: 5,
    comment: 'Sản phẩm tuyệt vời! Màn hình rất đẹp và hiệu năng mượt mà. Giao hàng nhanh chóng.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Review(
    id: 'review2',
    user: User(id: 'user2', username: 'thanh', email: 'thanh@email.com', firstName: 'Minh', lastName: 'Thanh', role: 'customer', avatarUrl: 'https://i.pravatar.cc/150?u=user2'),
    rating: 4,
    comment: 'Thiết kế sang trọng, pin dùng ổn. Camera chụp ảnh rất nét. Sẽ tiếp tục ủng hộ shop.',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];
