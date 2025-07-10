import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quên Mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nhập email đã đăng ký của bạn. Chúng tôi sẽ gửi một liên kết để đặt lại mật khẩu.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                 // TODO: Xử lý logic gửi email
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Hướng dẫn đã được gửi tới email của bạn!'))
                 );
                 context.pop();
              },
              child: const Text('Gửi hướng dẫn'),
            ),
          ],
        ),
      ),
    );
  }
}