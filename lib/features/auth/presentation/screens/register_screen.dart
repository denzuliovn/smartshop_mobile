import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tạo tài khoản'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Họ và Tên')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Xác nhận Mật khẩu'), obscureText: true),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Xử lý logic đăng ký
                context.go('/login');
              },
              child: const Text('Đăng ký'),
            ),
             const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Đã có tài khoản?'),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Đăng nhập'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}