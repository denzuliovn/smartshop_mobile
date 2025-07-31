// FILE PATH: lib/features/profile/presentation/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';
import 'package:smartshop_mobile/features/profile/application/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final String _userId;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    if (authState is Authenticated) {
      _userId = authState.user.id;
      _firstNameController = TextEditingController(text: authState.user.firstName);
      _lastNameController = TextEditingController(text: authState.user.lastName);
    } else {
      _userId = '';
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(editProfileProvider.notifier).updateProfile(
        userId: _userId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
    }
  }

  // ===== HÀM MỚI ĐỂ CHỌN ẢNH =====
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Hiển thị dialog cho người dùng chọn Camera hoặc Thư viện
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Nếu có ảnh, gọi Notifier để cập nhật
      await ref.read(editProfileProvider.notifier).updateAvatar(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EditProfileState>(editProfileProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      if (next is EditProfileSuccess) {
        messenger.showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.green),
        );
        if (mounted && Navigator.of(context).canPop()) {
           // Không pop() vì có thể user muốn sửa tiếp
        }
      } else if (next is EditProfileError) {
        messenger.showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    final editState = ref.watch(editProfileProvider);
    final authState = ref.watch(authProvider);
    final user = (authState is Authenticated) ? authState.user : null;
    final theme = Theme.of(context);

    if (user != null) {
      print('[UI] Màn hình EditProfile đang build với avatarUrl: ${user.avatarUrl}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ===== WIDGET AVATAR ĐÃ ĐƯỢC CẬP NHẬT =====
            Center(
              child: Stack(
                children: [
                  // Vòng tròn loading khi đang tải ảnh
                  if (editState is EditProfileLoading)
                    const SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(),
                    ),
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                        : null,
                  ),

                  // Nút chỉnh sửa
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: editState is EditProfileLoading ? null : _pickImage,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ... các TextFormField khác giữ nguyên ...
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Họ'),
              validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập họ' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Tên'),
              validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: user?.email,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: editState is EditProfileLoading ? null : _submit,
              child: editState is EditProfileLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu thay đổi thông tin'),
            ),
          ],
        ),
      ),
    );
  }
}