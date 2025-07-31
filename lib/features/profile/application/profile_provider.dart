// FILE PATH: lib/features/profile/application/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';
import 'package:smartshop_mobile/features/profile/data/profile_repository.dart';
import 'package:image_picker/image_picker.dart';

// Định nghĩa các trạng thái
abstract class EditProfileState {}
class EditProfileInitial extends EditProfileState {}
class EditProfileLoading extends EditProfileState {}
class EditProfileSuccess extends EditProfileState {
  final String message;
  EditProfileSuccess(this.message);
}
class EditProfileError extends EditProfileState {
  final String message;
  EditProfileError(this.message);
}

// StateNotifier
class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final Ref _ref;
  EditProfileNotifier(this._ref) : super(EditProfileInitial());

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName
  }) async {
    state = EditProfileLoading();
    try {
      final updatedUser = await _ref.read(profileRepositoryProvider).updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
      );

      // Cập nhật lại AuthProvider để thay đổi thông tin user trên toàn ứng dụng
      _ref.read(authProvider.notifier).updateUserData(updatedUser);

      state = EditProfileSuccess('Cập nhật thông tin thành công!');
    } catch (e) {
      state = EditProfileError(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  Future<void> updateAvatar(XFile imageFile) async {
    state = EditProfileLoading(); // Dùng chung state loading
    try {
      final updatedUser = await _ref.read(profileRepositoryProvider).updateAvatar(imageFile);

      // Cập nhật lại AuthProvider để thay đổi avatar trên toàn ứng dụng
      _ref.read(authProvider.notifier).updateUserData(updatedUser);

      state = EditProfileSuccess('Cập nhật avatar thành công!');
    } catch (e) {
      state = EditProfileError(e.toString().replaceFirst("Exception: ", ""));
    }
  }
}

// Provider
final editProfileProvider = StateNotifierProvider.autoDispose<EditProfileNotifier, EditProfileState>((ref) {
  return EditProfileNotifier(ref);
});