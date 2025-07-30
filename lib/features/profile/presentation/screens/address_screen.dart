import 'package:flutter/material.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ nhận hàng'),
      ),
      body: const Center(
        child: Text('Giao diện quản lý địa chỉ sẽ ở đây.'),
      ),
    );
  }
}