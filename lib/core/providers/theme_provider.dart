import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum để định nghĩa các chế độ giao diện
enum ThemeModeOption { light, dark, system }

// StateNotifier để quản lý logic thay đổi theme
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system); // Bắt đầu với theme của hệ thống

  void setThemeMode(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.light:
        state = ThemeMode.light;
        break;
      case ThemeModeOption.dark:
        state = ThemeMode.dark;
        break;
      case ThemeModeOption.system:
        state = ThemeMode.system;
        break;
    }
  }
}

// Provider để cung cấp ThemeNotifier cho toàn ứng dụng
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});