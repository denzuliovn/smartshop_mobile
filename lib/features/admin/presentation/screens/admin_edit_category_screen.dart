// FILE PATH: lib/features/admin/presentation/screens/admin_edit_category_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/admin/data/admin_repository.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';

class AdminEditCategoryScreen extends ConsumerStatefulWidget {
  final Category category;
  const AdminEditCategoryScreen({super.key, required this.category});

  @override
  ConsumerState<AdminEditCategoryScreen> createState() => _AdminEditCategoryScreenState();
}

class _AdminEditCategoryScreenState extends ConsumerState<AdminEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController = TextEditingController(text: ""); // Giả sử description chưa có
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
        };
        // Cần thêm hàm updateCategory vào AdminRepository
        // await ref.read(adminRepositoryProvider).updateCategory(widget.category.id, data);

        ref.refresh(categoriesProvider);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sửa Danh mục')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên danh mục'),
              validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _onSave,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Lưu thay đổi'),
            )
          ],
        ),
      ),
    );
  }
}