import 'package:flutter/material.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả Thương hiệu'),
      ),
      body: const Center(
        child: Text('Giao diện danh sách các thương hiệu sẽ được xây dựng ở đây.'),
      ),
    );
  }
}