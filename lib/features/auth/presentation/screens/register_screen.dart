import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      } else if (next is Unauthenticated && previous is AuthLoading) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    });

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
            TextField(controller: fullNameController, decoration: const InputDecoration(labelText: 'Họ và Tên')),
            const SizedBox(height: 16),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState is AuthLoading ? null : () {
                ref.read(authProvider.notifier).register(
                  username: emailController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  firstName: fullNameController.text.split(' ').first,
                  lastName: fullNameController.text.split(' ').length > 1
                      ? fullNameController.text.split(' ').last
                      : '', 
                );
              },
              child: authState is AuthLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}