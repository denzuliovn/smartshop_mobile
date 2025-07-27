import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final authState = ref.watch(authProvider);

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
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState is AuthLoading ? null : () {
                 ref.read(authProvider.notifier).forgotPassword(emailController.text);
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Nếu email tồn tại, hướng dẫn đã được gửi đi!'))
                 );
                 context.pop();
              },
              child: authState is AuthLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Gửi hướng dẫn'),
            ),
          ],
        ),
      ),
    );
  }
} 