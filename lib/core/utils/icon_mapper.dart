import 'package:flutter/material.dart';

class IconMapper {
  // --- BỘ ÁNH XẠ CHO DANH MỤC ---
  // Key là tên danh mục (viết thường, không dấu)
  static final Map<String, IconData> _categoryIcons = {
    'smart phones': Icons.phone_android,
    'laptops': Icons.laptop_mac,
    'smart home': Icons.home,
    'wearables': Icons.watch,
    'audio': Icons.headset,
  };

  // --- BỘ ÁNH XẠ CHO THƯƠNG HIỆU ---
  // Key là tên thương hiệu (viết thường)
  static final Map<String, IconData> _brandIcons = {
    'apple': Icons.apple,
    'samsung': Icons.phone_android, // Có thể dùng icon chung
    'xiaomi': Icons.phone_android,
    'sony': Icons.camera_alt,
    'dell': Icons.laptop_windows,
  };

  // Hàm để lấy icon cho danh mục
  static IconData getCategoryIcon(String categoryName) {
    // Chuẩn hóa tên: viết thường, không dấu, bỏ ký tự đặc biệt
    final normalizedName = categoryName.toLowerCase()
      .replaceAll('đ', 'd')
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    
    // Tìm key tương ứng
    for (var key in _categoryIcons.keys) {
      if (normalizedName.contains(key)) {
        return _categoryIcons[key]!;
      }
    }
    
    // Icon mặc định nếu không tìm thấy
    return Icons.category;
  }

  // Hàm để lấy icon cho thương hiệu
  static IconData getBrandIcon(String brandName) {
    final normalizedName = brandName.toLowerCase();

    for (var key in _brandIcons.keys) {
      if (normalizedName.contains(key)) {
        return _brandIcons[key]!;
      }
    }

    return Icons.store; // Icon mặc định
  }
}