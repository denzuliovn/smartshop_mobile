import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả Danh mục'),
      ),
      body: const Center(
        child: Text('Giao diện danh sách các danh mục sẽ được xây dựng ở đây.'),
      ),
    );
  }
}