import 'models.dart';

// ----- MOCK DATA -----

final mockUser = User(
  id: 'customer1',
  username: 'takiya',
  email: 'customer1@gmail.com',
  firstName: 'Takiya',
  lastName: 'Genji',
  role: 'customer',
  avatarUrl: 'https://i.pravatar.cc/150?u=customer1',
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
  Category(id: 'cat1', name: 'Smart Phones', imageUrl: 'https://cdn-icons-png.flaticon.com/512/644/644458.png'),
  Category(id: 'cat2', name: 'Laptops', imageUrl: 'https://cdn-icons-png.flaticon.com/512/428/428001.png'),
  Category(id: 'cat3', name: 'Smart Home', imageUrl: 'https://cdn-icons-png.flaticon.com/512/3063/3063821.png'),
  Category(id: 'cat4', name: 'Wearables', imageUrl: 'https://cdn-icons-png.flaticon.com/512/3429/3429397.png'),
  Category(id: 'cat5', name: 'Audio', imageUrl: 'https://cdn-icons-png.flaticon.com/512/3081/3081541.png'),
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
    images: ['https://images.unsplash.com/photo-1695026139365-341328054c0e?q=80&w=800'],
    stock: 50,
    isFeatured: true,
    category: mockCategories[0],
    brand: mockBrands[0]
  ),
  Product(
    id: 'prod2',
    name: 'Samsung Galaxy S24 Ultra 12GB 512GB - Xám Titan',
    description: 'Galaxy AI is here. Tìm kiếm nhanh hơn, giao tiếp thông minh hơn, sáng tạo dễ dàng hơn. Cùng với khung titan bền bỉ và camera 200MP xuất sắc.',
    price: 30490000,
    originalPrice: 37490000,
    images: ['https://images.unsplash.com/photo-1707345512638-997d31a1052c?q=80&w=800'],
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
    images: ['https://images.unsplash.com/photo-1628191080183-16a79354d8a5?q=80&w=800'],
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
    images: ['https://images.unsplash.com/photo-1652705051184-3c5513f5b74c?q=80&w=800'],
    stock: 60,
    isFeatured: false,
    category: mockCategories[4],
    brand: mockBrands[3]
  ),
];