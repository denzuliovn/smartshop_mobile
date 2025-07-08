import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    // Bảng màu chính
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF7F8FC), // Một màu xám rất nhạt

    // Font chữ - Dùng Inter như trên web
    fontFamily: GoogleFonts.inter().fontFamily,

    // Chủ đề cho AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0.5,
      iconTheme: const IconThemeData(color: Colors.black87),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      centerTitle: true,
    ),

    // Chủ đề cho các nút
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600], // Màu nút chính
        foregroundColor: Colors.white, // Màu chữ
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.blue.withOpacity(0.2),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    
    // Chủ đề cho các ô nhập liệu
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    ),

    // Chủ đề cho Card
    cardTheme: CardThemeData(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
    ),

    // Chủ đề cho Text
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(fontSize: 16),
      bodyMedium: GoogleFonts.inter(fontSize: 14),
      bodySmall: GoogleFonts.inter(fontSize: 12),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );
}