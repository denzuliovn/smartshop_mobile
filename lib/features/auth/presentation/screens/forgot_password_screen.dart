import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  int _step = 1; // 1 for email, 2 for OTP and new password
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  
  void _handleSendOTP() {
    if (_emailController.text.isEmpty) return;
    ref.read(authProvider.notifier).forgotPassword(_emailController.text.trim());
  }

  void _handleResetPassword() {
    if (_otpController.text.isEmpty || _passwordController.text.isEmpty) return;
    ref.read(authProvider.notifier).resetPassword(
      _emailController.text.trim(),
      _otpController.text.trim(),
      _passwordController.text.trim()
    );
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next is Unauthenticated && previous is AuthLoading) {
        if (_step == 1) { // Sau khi gửi OTP thành công
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP đã được gửi!'), backgroundColor: Colors.green));
          setState(() => _step = 2);
        } else if (_step == 2) { // Sau khi reset thành công
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt lại mật khẩu thành công!'), backgroundColor: Colors.green));
          context.go('/login');
        }
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Quên Mật khẩu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _step == 1 ? _buildEmailStep(authState) : _buildOtpStep(authState),
      ),
    );
  }

  Widget _buildEmailStep(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nhập email đã đăng ký của bạn. Chúng tôi sẽ gửi mã OTP.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: authState is AuthLoading ? null : _handleSendOTP,
          child: authState is AuthLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gửi mã OTP'),
        ),
      ],
    );
  }

  Widget _buildOtpStep(AuthState authState) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mã OTP đã được gửi tới email ${_emailController.text}. Vui lòng kiểm tra và nhập vào bên dưới.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(controller: _otpController, decoration: const InputDecoration(labelText: 'Mã OTP')),
        const SizedBox(height: 16),
        TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu mới'), obscureText: true),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: authState is AuthLoading ? null : _handleResetPassword,
          child: authState is AuthLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Xác nhận'),
        ),
      ],
    );
  }
}