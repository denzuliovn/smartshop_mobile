import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
      ),
      body: const Center(
        child: Text('Giao diện chỉnh sửa thông tin cá nhân sẽ ở đây.'),
      ),
    );
  }
}