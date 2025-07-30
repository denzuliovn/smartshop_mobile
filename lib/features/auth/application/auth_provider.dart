import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/api/graphql_client.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/auth/data/auth_repository.dart';

// Định nghĩa các trạng thái
abstract class AuthState { const AuthState(); }
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// Provider chính
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// Notifier xử lý logic
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  
  AuthNotifier(this._ref) : super(AuthLoading()) {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = Unauthenticated();
  }

  Future<void> login(String username, String password) async {
    state = AuthLoading();
    try {
      final responseData = await _ref.read(authRepositoryProvider).login(username, password);
      final userMap = responseData['user'];
      final token = responseData['jwt'];

      await GraphQLConfig.setToken(token, userMap);

      final user = User(
        id: userMap['_id'],
        username: userMap['username'],
        email: userMap['email'],
        firstName: userMap['firstName'],
        lastName: userMap['lastName'],
        role: userMap['role'],
        avatarUrl: 'https://i.pravatar.cc/150?u=${userMap['_id']}',
      );
      
      state = Authenticated(user);

    } catch (e) {
      state = AuthError(e.toString().replaceFirst("Exception: ", ""));
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) state = Unauthenticated();
    }
  }
  
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName
  }) async {
    state = AuthLoading();
    try {
      await _ref.read(authRepositoryProvider).register(
        username: username, email: email, password: password,
        firstName: firstName, lastName: lastName
      );
      state = Unauthenticated();
    } catch(e) {
      state = AuthError(e.toString().replaceFirst("Exception: ", ""));
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) state = Unauthenticated();
    }
  }

  // --- HÀM CÒN THIẾU ĐÃ ĐƯỢC THÊM VÀO ĐÂY ---
  Future<void> forgotPassword(String email) async {
    state = AuthLoading();
    try {
      await _ref.read(authRepositoryProvider).sendOTP(email);
      // Giữ trạng thái Unauthenticated để user có thể ở lại màn hình nhập OTP
      state = Unauthenticated(); 
    } catch (e) {
      state = AuthError(e.toString().replaceFirst("Exception: ", ""));
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) state = Unauthenticated();
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    state = AuthLoading();
     try {
      await _ref.read(authRepositoryProvider).resetPassword(email, otp, newPassword);
      state = Unauthenticated();
    } catch (e) {
      state = AuthError(e.toString().replaceFirst("Exception: ", ""));
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) state = Unauthenticated();
    }
  }

  
  Future<void> logout() async {
    state = AuthLoading();
    await GraphQLConfig.clearToken();
    await Future.delayed(const Duration(milliseconds: 500));
    state = Unauthenticated();
  }
}